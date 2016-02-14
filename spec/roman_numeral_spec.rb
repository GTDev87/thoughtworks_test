require "roman_numeral"

RSpec.describe RomanNumeral, "#roman_numeral_to_integer" do
  context "tranlate roman numerals into integers" do 
    it "should translate numerals properly" do
      expect(RomanNumeral.roman_numeral_to_integer("xxxi")).to eq 31
    end

    it "should translate empty to 0" do
      expect(RomanNumeral.roman_numeral_to_integer("")).to eq 0
    end

    it "should not allow non strings" do
      expect {RomanNumeral.roman_numeral_to_integer(2)}.to raise_error("is not a string")
    end

    it "should not translate with same var 4 times" do
      expect {RomanNumeral.roman_numeral_to_integer("xxxx")}.to raise_error("four of same value in a row [x]")
    end

    it "should not allow value bigger than subtracion after subtraction" do
      expect {RomanNumeral.roman_numeral_to_integer("ivi")}.to raise_error("previously used subtraction [i]")
    end

    it "should not let roman numeral values get bigger" do
      expect {RomanNumeral.roman_numeral_to_integer("ivx")}.to raise_error("values should not be getting bigger [x]")
    end

    it "should not allow non roman numeral characters" do
      expect {RomanNumeral.roman_numeral_to_integer("g")}.to raise_error("non roman numeral character [g]")
      expect {RomanNumeral.roman_numeral_to_integer("ig")}.to raise_error("non roman numeral character [g]")
    end

    it "should not allow subtraction of 'v', 'l', 'd' " do
      expect {RomanNumeral.roman_numeral_to_integer("vx")}.to raise_error("cannot subtract [v] from [x]")
      expect {RomanNumeral.roman_numeral_to_integer("lc")}.to raise_error("cannot subtract [l] from [c]")
      expect {RomanNumeral.roman_numeral_to_integer("dm")}.to raise_error("cannot subtract [d] from [m]")
    end
  end
end