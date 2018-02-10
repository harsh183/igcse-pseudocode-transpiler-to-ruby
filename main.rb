require 'pry'

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

# TODO: Make sure the code conversions don't affect things inside strings (maybe write your own version of gsub that ignores comments and strings)
def convert(code)
  output_text = ''
  output_lines = []
  code.lines.each do |line|
    # Type conversions (from psudocode to ruby)
    # TODO: Fix compound expressions with conversion
    # TODO: Handle multiple conversions per line
    type_conversions = { str: '.to_s',
                         int: '.to_i',
                         float: '.to_f' }
    type_conversions.each do |type, ruby_code|
      # TODO: Better way to skip print (since it has int in it's name)
      unless line.index('print').nil?
        next
      end

      # Find occupancies of the type conversion
      start_point = line.index(type.to_s)
      next if start_point.nil?

      # binding.pry
      end_point = line[start_point..line.length].index(')') + 2
      substring = line[start_point..end_point]
      # TODO: Parse code inside the bracket
      binding.pry if substring.split('(')[1].nil?
      replacement = '('+ substring.split('(')[1].split(')')[0] + ')' + ruby_code

      line = line.gsub(substring, replacement)
    end

    # Convert all the endings of blocks properly
    block_endings = ['endif', 'endfunction', 'endwhile', 'endprocedure']
    block_endings.each do |ending|
      line.gsub!(ending, 'end')
    end

    # Get rid of then
    line.gsub!('then', '')

    # Convert elseif to elsif
    line.gsub!('elseif', 'elsif')

    # Convert logical operations to ruby equivalent
    logical_operations = { 'MOD' => '%',
                           'DIV' => '/',
                           '^'   => '**' }
    logical_operations.each do |operation, ruby_operation|
      line.gsub!(operation.to_s, ruby_operation)
    end

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

    # Handle comments
    # Note: I'm moving the comments over anyway
    # TODO: Make sure there is an escape
    line.gsub!('//', '#')

    output_lines.push line
  end

  output_text << output_lines.join("\n")
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

File.open('input.txt', 'r') do |f|
  code = f.read
  output_text << convert(code)
end

puts output_text

File.write('output.rb', output_text)