require File.expand_path("../roman_numeral", __FILE__)

module Parsers

  def self.return_or_raise(obj, field)
    if !obj[field] then raise "there is no value " + field else obj[field] end
  end

  def self.return_or_raise2(obj, field1, field2)
    if !obj[field1] then raise "there is no value " + field1 end
    if !obj[field1][field2] then raise "there is no value " + field1 + "," + field2 else obj[field1][field2] end
  end

  # "glob is I"
  class NumeralParser
    def initialize(line)
      split = line.split(" is ")
      @numeral_translation = split[0]
      @numeral = split[1]
    end

    def condition()
      return @numeral_translation.split(" ").length == 1 && @numeral.split(" ").length == 1
    end

    def process(numeral_obj, ledger)
      obj = numeral_obj || {}
      obj[@numeral_translation] = @numeral
      return [obj, ledger, nil]
    end
  end

  # "glob glob Silver is 34 Credits"
  class RatioParser
    def initialize(line)
      split = line.split(" is ")
      @roman_value = split[0]
      @num_value = split[1]
    end

    def condition()
      if !@num_value then return false end
      num_split = @num_value.split(" ")
      return (num_split.length == 2) && (true if Integer(num_split.first) rescue false) && (@roman_value.length >= 1)
    end

    def process(numeral_obj, prev_ledger)
      roman_split = @roman_value.split(" ")
      num_split = @num_value.split(" ")

      roman_only = roman_split.first(roman_split.length - 1)
      material = roman_split.last

      number_denomination = num_split.first.to_i
      denomination = num_split.last

      roman_count = RomanNumeral.roman_numeral_to_integer(roman_only.map{|trans| Parsers.return_or_raise(numeral_obj || {}, trans) }.join(""))
      ledger = prev_ledger || {}
      ledger[material] = (ledger[material] || {})
      ledger[material][denomination] = number_denomination.to_f / roman_count.to_f;

      return [numeral_obj, ledger, nil]
    end
  end

  # "how much is pish tegj glob glob?"
  class CountParser
    def initialize(line)
      @line = line
    end

    def condition()
      return @line.index("how much is ") == 0 && @line[@line.length - 1] == "?"
    end

    def process(numeral_obj, ledger)
      numeral = @line.sub("how much is ", "").chomp("?").strip()
      result = RomanNumeral.roman_numeral_to_integer(numeral.split(" ").map{|trans| Parsers.return_or_raise(numeral_obj || {}, trans) }.join(""))
      res = numeral + " is " + result.to_s
      return [numeral_obj, ledger, res]
    end
  end

  # "how many Credits is glob prok Silver ?"
  class ValueParser
    def initialize(line)
      @line = line
    end

    def condition()
      prefix_index = @line.index("how many ")
      rest = @line.sub("how many ", "")

      split = rest.split(" is ")
      denomination = split[0]
      roman_value = split[1]

      return denomination.split(" ").length == 1 && roman_value.split(" ").length >= 1 && rest[rest.length - 1] == "?"
    end

    def process(numeral_obj, ledger)
      prefix_index = @line.index("how many ")
      rest = @line.sub("how many ", "").chomp("?").strip()

      split = rest.split(" is ")
      denomination = split[0]
      roman_value = split[1]
      
      roman_split = roman_value.split(" ")
      roman_only = roman_split.first(roman_split.length - 1)
      material = roman_split.last

      count = RomanNumeral.roman_numeral_to_integer(roman_only.map{|trans| Parsers.return_or_raise(numeral_obj || {}, trans) }.join(""))
      result = (Parsers.return_or_raise2(ledger, material, denomination) * count).to_i
      res = roman_value + " is " + result.to_s + " " + denomination
      return [numeral_obj, ledger, res]
    end
  end
end