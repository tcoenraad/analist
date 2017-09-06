def good_func
  puts 1 + 1 + 1
  puts 'a' + 'a'
end

def bad_func
  puts 'a' + 1
  puts 1 + 'a'
end

good_func(true)
bad_func
