# START of BASE functions
def input(string = 'Enter string')
  puts string
  gets.chomp
end

def print(string = '')
  puts(string)
end

def init_array(dimensions = [10], default_element = nil)
  size = dimensions.first
  if dimensions.length > 1
    dimensions.shift
    Array.new(size, init_array(dimensions, default_element))
  else
    Array.new(size, default_element)
  end
end

# END of BASE functions