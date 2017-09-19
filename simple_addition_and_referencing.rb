# frozen_string_literal: true

def bad_func_with_arg(arg)
  puts arg
  some_string = 'a'
  puts 1 + some_string + 'a'
end

def good_func
  puts 1 + 1 + 1
  puts 'a' + 'a' + 'a'
end

bad_func
bad_func_with_arg
bad_func_with_arg(true)

{} << 2
