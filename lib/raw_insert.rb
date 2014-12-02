require "raw_insert/version"

module RawInsert
  def raw_insert(enum)
    table_definition_hash = define_table_structure enum.first
    insert_lines = create_insert_lines enum, table_definition_hash
    execute_copy_from_on insert_lines, table_definition_hash
  end

  private
  def define_table_structure(model)
    table_structure = {}
    klass = model.class
    table_structure[:table_name] = klass.table_name
    table_structure[:columns] = klass.new.attributes.keys - klass.protected_attributes.to_a
    return table_structure
  end

  def create_insert_lines(enum, table_structure)
    keys = table_structure[:columns]
    new_lines = []

    str = ""
    enum.each do |ra|
      keys.each_with_index do |k,i|
        str += "#{ra[k]}"
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
        Rails.logger.info "Raw insert success"
      end
    end # very important to do this after a copy
    ActiveRecord::Base.connection_pool.checkin(conn)
    Rails.logger.info @errmsg
  end
end
