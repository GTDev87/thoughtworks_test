module RomanNumeral
  def self.create_roman_numeral_obj()
    roman_numeral = { }
    roman_numeral['i'] = 1
    roman_numeral['v'] = 5
    roman_numeral['x'] = 10
    roman_numeral['l'] = 50
    roman_numeral['c'] = 100
    roman_numeral['d'] = 500
    roman_numeral['m'] = 1000
    return roman_numeral
  end

  @unsubtractable = ['v', 'l', 'd']
  @roman_numeral_obj = self.create_roman_numeral_obj()

  def self.subtracted_from(current_value, prev_values)
    return current_value == prev_values.first && prev_values[1] == -1
  end

  def self.four_in_a_row(current_value, prev_values)
    return current_value == prev_values.first && prev_values[1] == 3
  end

  def self.bigger_than_last_value(current_value, prev_values)
    return current_value > prev_values.first
  end

  def self.to_roman(numeral_array, prev_values)
    length = numeral_array.length
    if length == 0 then return 0 end

    current_value = @roman_numeral_obj[numeral_array.first]

    if prev_values and subtracted_from(current_value, prev_values) then raise "previously used subtraction [#{numeral_array.first}]" end
    if prev_values and four_in_a_row(current_value, prev_values) then raise "four of same value in a row [#{numeral_array.first}]" end
    if prev_values and bigger_than_last_value(current_value, prev_values) then raise "values should not be getting bigger [#{numeral_array.first}]" end
    if current_value == nil then raise "non roman numeral character [#{numeral_array.first}]" end
    if length == 1 then return current_value end

    second_value = @roman_numeral_obj[numeral_array[1]]

    if second_value == nil then raise "non roman numeral character [#{numeral_array[1]}]" end

    is_smaller_value = current_value < second_value

    if is_smaller_value && @unsubtractable.include?(numeral_array.first) then raise "cannot subtract [#{numeral_array.first}] from [#{numeral_array[1]}]" end
    if is_smaller_value then return (second_value - current_value) + to_roman(numeral_array.last(length - 2), [current_value, -1]) end

    return current_value + to_roman(numeral_array.last(length - 1), [current_value, (prev_values && prev_values.first == current_value ? prev_values[1] : 0) + 1])
  end

  def self.roman_numeral_to_integer(numeral_string)
    is_a_string = (numeral_string.is_a? String)
    if not is_a_string then raise "is not a string" end

    downcase_string = numeral_string.downcase
    return to_roman(downcase_string.split(""), nil)
  end
end