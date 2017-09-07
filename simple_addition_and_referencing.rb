def bad_func
  puts 'a' + 1
  puts 'a' + 1 + 1
  puts 1 + 'a'
  puts 1 + 'a' + 'a'
end

def good_func
  puts 1 + 1 + 1
  puts 'a' + 'a' + 'a'
end

bad_func
good_func(true)
