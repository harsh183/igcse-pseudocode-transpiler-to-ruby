require 'pry'

# TODO: Make sure the code conversions don't affect things inside strings (maybe write your own version of gsub that ignores comments and strings)
# TODO: Escape variable names that contain part of a command
def convert(code)
  output_text = ''
  output_lines = []
  code.lines.each do |line|
    # Handle comments
    line = handle_comments(line)

    line = handle_type_conversions(line)

    # Convert all the endings of blocks properly
    block_endings = ['endif', 'endfunction', 'endwhile', 'endprocedure', 'endswitch']
    block_endings.each do |ending|
      line.gsub!(ending, 'end')
    end

    # Get rid of then
    line.gsub!('then', '')

    # Convert elseif to elsif
    line.gsub!('elseif', 'elsif')

    # Handle switch-case
    line = handle_switch_case(line)

    # Convert logical operations to ruby equivalent
    logical_operations = { 'MOD' => '%',
                           'DIV' => '/',
                           '^'   => '**' }
    logical_operations.each do |operation, ruby_operation|
      line.gsub!(operation.to_s, ruby_operation)
    end

    # Handle arrays
    # line = handle_array_init(line)

    # Handle functions
    line.gsub!('function', 'def')

    # Handle procedures
    line.gsub!('procedure', 'def')

    # Handle for loops
    line = handle_for_loops(line)

    # Handle do..until loops
    # Note: Since I don't think there are any exit controlled loops in ruby
    #       I'm making one by hand using an infinite loop and break statements
    line.gsub!('do', 'while true')
    line = handle_do_until_loop_end(line)

    # Handle substring
    line = handle_substring(line)

    output_lines.push line
  end

  output_text << output_lines.join("\n")
end

# Type conversions (from psudocode to ruby)
def handle_type_conversions(line)
  type_conversions = { str: 'String',
                       int: 'Integer',
                       float: 'Float' }
  type_conversions.each do |type, ruby_code|
    # TODO: Better way to skip print (since it has int in it's name)
    unless line.index('print').nil?
      next
    end

    line = line.gsub(type.to_s, ruby_code)
  end

  return line
end

# TODO: Escape strings
def handle_comments(line)
  if line.start_with?('//')
    line = ''
  elsif line.include? '//'
    line = line[0..line.index('//') - 1]
  end
  return line
end

# TODO: Make this more generalized (i.e this only works when the array is declared on it's own line)
def handle_array_init(line)
  line = line.gsub('Array', 'array')
  if line.include?('array')
    variable_name = line.split('array').last
    variable_name = variable_name.delete("\n")
    dimensions = '[' + variable_name.split('[').last
    binding.pry
  end
  return line
end

# Note: Since psudocode uses case to indicate each branch and ruby
#       uses case to indicate the block, we should parse case first
#       and then the block header
def handle_switch_case(line)
  line = handle_case_header(line)
  line = handle_switch_header(line)
  line = handle_switch_default(line)
  return line
end

def handle_case_header(line)
  line = line.gsub('case', 'when')
  line = line.delete(':')
  return line
end

def handle_switch_header(line)
  line = line.gsub('switch', 'case')
  line = line.delete(':')
  return line
end

def handle_switch_default(line)
  line = line.gsub('default', 'else')
  line = line.delete(':')
  return line
end

def handle_do_until_loop_end(line)
  if line.include?('until')
    condition = line.split('until').last

    line = "    break if #{condition}\nend"
  end

  return line
end

def handle_for_loops(line)
  line = handle_for_loop_header(line)
  line = handle_for_loop_end(line)
  return line
end

def handle_for_loop_header(line)
  unless line.index('for').nil?
    range_text = line.split('=')[1]
    range_code_for_ruby = range_text.delete(' ').gsub('to', '..')
    line.gsub!('=', ' in ')
    line.gsub!(range_text, range_code_for_ruby)
  end

  return line
end

def handle_for_loop_end(line)
  line = 'end' unless line.index('next').nil?
  return line
end

# Note: IGCSE defines subString(startingPosition, numberOfCharacters), this is equivalent to ruby slice
def handle_substring(line)
  line = line.gsub('substring', 'slice')
  return line
end

def get_matching_bracket(string, open_bracket_index)
  index = open_bracket_index
  depth = 0 # Depth is how deep within a nested bracket is

  chars = string[index..string.length]

  chars.each_char do |char|
    if char == '('
      depth += 1
    elsif char == ')'
      depth -= 1
    end

    if depth == 0
      break
    end

    index += 1
  end

  return index
end

output_text = ''

# Add input function into the code output
output_text << 'def input(string="Enter string")' + "\n"
output_text << ' puts string' + "\n"
output_text << ' enteredText = gets.chomp' + "\n"
output_text << ' return enteredText' + "\n"
output_text << 'end' + "\n"
output_text << "\n"

# Redo print function
output_text << 'def print(string="")' + "\n"
output_text << '  puts(string)'+ "\n"
output_text << 'end'+ "\n"
output_text << "\n"

# Create an array init function

File.open('input.txt', 'r') do |f|
  code = f.read
  output_text << convert(code)
end

puts output_text

File.write('output.rb', output_text)