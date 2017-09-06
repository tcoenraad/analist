Analysis
========

## Usage
```bash
$ bundle exec ruby analyzer.rb -f simple_addition_and_referencing.rb
simple_addition_and_referencing.rb:7 Coerce error
  puts 'a' + 1
simple_addition_and_referencing.rb:8 Coerce error
  puts 1 + 'a'
```