Analysis
========
[![Build Status](https://travis-ci.com/tcoenraad/analist.svg?token=VRpTPqQimpVvBRMqjtwB&branch=master)](https://travis-ci.com/tcoenraad/analist)

## Usage
```bash
$ bundle exec ruby analyzer.rb -f simple_addition_and_referencing.rb
simple_addition_and_referencing.rb:15 ArgumentError, expected 1, actual: 0
  bad_func_with_arg
---
simple_addition_and_referencing.rb:18 NoMethodError: undefined method `<<' for (hash)'
  {} << 2
---
simple_addition_and_referencing.rb:6 TypeError: int cannot be coerced into str
    puts 1 + some_string + 'a'
---
```
