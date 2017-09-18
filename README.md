Analysis
========
[![Build Status](https://travis-ci.com/tcoenraad/analist.svg?token=VRpTPqQimpVvBRMqjtwB&branch=master)](https://travis-ci.com/tcoenraad/analist)

## Usage
```bash
$ bundle exec ruby analyzer.rb -f simple_addition_and_referencing.rb
simple_addition_and_referencing.rb:18 ArgumentError, expected 1, actual: 0
  bad_func_with_arg
---
simple_addition_and_referencing.rb:20 ArgumentError, expected 1, actual: 2
  bad_func_with_arg(true, false)
---
simple_addition_and_referencing.rb:2 TypeError
    puts 'a' + 1
---
simple_addition_and_referencing.rb:3 TypeError
    puts 'a' + 1 + 1
---
simple_addition_and_referencing.rb:8 TypeError
    puts 1 + 'a'
---
simple_addition_and_referencing.rb:9 TypeError
    puts 1 + 'a' + 'a'
---
```
