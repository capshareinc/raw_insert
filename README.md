# RawInsert

Takes an enum of models, dynamically creates a raw insert sql statement to shove that data into your Postgres database. Simple.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'raw_insert'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raw_insert

## Usage

Add this to your class:
```
include RawInsert
```

Call the raw_insert method whenever you need to jam in teh dataz. Pass in an enumerable collection of models.
```
raw_insert(my_models_to_insert)
```

Enjoy!

## Contributing

1. Fork it ( https://github.com/[my-github-username]/raw_insert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
