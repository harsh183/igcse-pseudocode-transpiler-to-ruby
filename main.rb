require 'pry'

# TODO: Create test cases
# TODO: Make sure the code conversions don't affect things inside strings (maybe write your own version of gsub that ignores comments and strings) - or learn regex lmao
# TODO: Escape variable names that contain part of a command

# List of arrays
arrays = []

def convert(code)
  output_text = ''
  output_lines = []
  code.lines.each do |line|
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


    line = handle_switch_case(line)

    line = handle_arithmetic_operations(line)
    line = handle_logical_operations(line)

    line = handle_array_init(line)
    line = handle_multidimensional_array_assign(line)

    line = handle_read_line(line)
    line = handle_write_line(line)
    line = handle_end_of_file(line)

    # Functions and procedures
    line.gsub!('function', 'def')
    line.gsub!('procedure', 'def')


    line = handle_for_loops(line)

    # Handle do..until loops
    # Note: Since I don't think there are any exit controlled loops in ruby
    #       I'm making one by hand using an infinite loop and break statements
    line.gsub!('do', 'while true')
    line = handle_do_until_loop_end(line)

    line = handle_substring(line)

    output_lines.push line
  end

  output_text << output_lines.join
end

def handle_multidimensional_array_assign(line)
  if line.include? '='
    address_in_psudocode = '[' + line.split('=').first.split('[').last # EX: [5, 10, 2]
    address_in_psudocode = address_in_psudocode.delete(' ')
    address_in_ruby = address_in_psudocode.gsub(',', '][')
    line = line.gsub(address_in_psudocode, address_in_ruby)
  end

  return line
end

def handle_arithmetic_operations(line)
  arithmetic_operations = { 'MOD' => '%',
                            'DIV' => '/',
                            '^'   => '**' }
  arithmetic_operations.each do |operation, ruby_operation|
    line = line.gsub(operation.to_s, ruby_operation)
  end

  return line
end

def handle_logical_operations(line)
  logical_operations = { 'AND' => '&&',
                         'OR'  => '||',
                         'NOT' => '!' }
  logical_operations.each do |operation, ruby_operation|
    line = line.gsub(operation.to_s, ruby_operation)
  end

  return line
end

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
    array_identifer = line.split('array').last
    array_identifer = array_identifer.delete("\n")
    #varible_name = array_identifer.split('[').first
    dimensions = '[' + array_identifer.split('[').last
    function_args = dimensions.gsub('][', ', ')

    line.slice!('array')
    line = line.gsub(dimensions, " = init_array(#{function_args})")
  end
  return line
end

def handle_switch_case(line)
  # Note: Since psudocode uses case to indicate each branch and ruby
  #       uses case to indicate the block, we should parse case first
  #       and then the block header
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

def handle_substring(line)
  # Note: IGCSE defines subString(startingPosition, numberOfCharacters), this is equivalent to ruby slice
  line = line.gsub('substring', 'slice')
  return line
end

def handle_read_line(line)
  line = line.gsub('readLine', 'gets')
end

def handle_write_line(line)
  line = line.gsub('writeLine', 'puts')
end

def handle_end_of_file(line)
  line = line.gsub('endOfFile', 'eof?')
end

output_text = ''

output_text << File.read('base_lib.rb')

File.open('input.txt', 'r') do |f|
  code = f.read
  output_text << convert(code)
end

puts output_text

File.write('output.rb', output_text)