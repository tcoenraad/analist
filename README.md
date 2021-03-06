# Analist
[![Build Status](https://travis-ci.org/tcoenraad/analist.svg?branch=master)](https://travis-ci.org/tcoenraad/analist)

A static analysis tool for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'analist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install analist

## Usage

```ruby
$ bundle exec analist -s ./spec/support/sql/users.sql
Inspecting 23 files
example.rb:3 TypeError: expected `[Integer]` args types, actual `[String]`
example.rb:4 TypeError: expected `[Array]` args types, actual `[Integer]`
example.rb:6 TypeError: expected `[Integer]` args types, actual `[String]`
example.rb:7 TypeError: expected `[Integer]` args types, actual `[String]`
23 files inspected, 4 errors found
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tcoenraad/analist.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
