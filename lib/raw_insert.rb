require "raw_insert/version"

module RawInsert
  def raw_insert(enum, opts={})
    return if empty? enum
    enum = [enum] unless iterable?(enum)
    table_definition_hash = define_table_structure enum.first, opts[:ignored_columns]
    insert_lines = create_insert_lines enum, table_definition_hash
    execute_copy_from_on insert_lines, table_definition_hash
  end

  private
  def empty?(enum)
    if enum.first.nil?
      Rails.logger.info "RawInsert aborted. Nothing to insert."
      return true
    else
      return false
    end
  end

  def define_table_structure(model, ignored_columns=[])
    table_structure = {}
    klass = model.class
    table_structure[:table_name] = klass.table_name
    table_structure[:columns] = column_definitions klass, ignored_columns
    return table_structure
  end

  def column_definitions(klass, ignored_columns)
    ignored_columns ||= []
    raise ArgumentError.new(":ignored_columns must be an array") unless ignored_columns.is_a? Array
    cols_to_remove = ['id'] + ignored_columns.map(&:to_s)
    klass.column_names - cols_to_remove
  end

  def create_insert_lines(enum, table_structure)
    keys = table_structure[:columns]
    new_lines = []

    str = ""
    enum.each do |ra|
      keys.each_with_index do |k,i|
        if ['created_at', 'updated_at'].include? k
          str += "#{Time.now}"
        else
          str += "#{ra[k]}"
        end
        str += "\t" unless i == (keys.length - 1)
      end
      str += "\n"
      new_lines << str
      str = ""
    end
    return new_lines
  end

  def execute_copy_from_on(insert_lines, table_structure)
    conn = ActiveRecord::Base.connection_pool.checkout
    raw  = conn.raw_connection
    raw.exec("COPY #{table_structure[:table_name]} (#{table_structure[:columns].join(', ')}) FROM STDIN WITH NULL AS ''")
    insert_lines.each do |line|
      raw.put_copy_data line
    end

    raw.put_copy_end
    @errmsg = ""
    while res = raw.get_result do
      if (res.result_status != 1)
        error = true
        @errmsg = @errmsg + "Result of COPY is: %s" % [ res.res_status(res.result_status) ]
        Rails.logger.info "Res:#{res.class}"
        Rails.logger.info "Res.result_status:#{res.result_status.class}"
        Rails.logger.info "Res.error_messages:#{res.error_message}"
        Rails.logger.info "Res.result_error_message:#{res.result_error_message}"
      else
        Rails.logger.info "RawInsert success!"
      end
    end # very important to do this after a copy
    ActiveRecord::Base.connection_pool.checkin(conn)
    Rails.logger.info @errmsg
  end

  def iterable?(object)
    object.respond_to? :each
  end
end
