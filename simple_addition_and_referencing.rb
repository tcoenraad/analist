# frozen_string_literal: true

def bad_func
  puts 'a' + 1
  puts 'a' + 1 + 1
end

def bad_func_with_arg(arg)
  puts arg
  puts 1 + 'a'
  puts 1 + 'a' + 'a'
end

def good_func
  puts 1 + 1 + 1
  puts 'a' + 'a' + 'a'
end

bad_func
bad_func_with_arg
bad_func_with_arg(true)
bad_func_with_arg(true, false)
good_func
