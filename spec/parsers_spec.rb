require "parsers"

RSpec.describe Parsers, "functions" do
  context "NumeralParser" do 
    describe "condition" do
      it "should be valid with proper format translate numerals properly" do
        parser = Parsers::NumeralParser.new("glob is I")
        expect(parser.condition).to eq true
      end

      it "should be throw false with 2 word roman numeral" do
        parser = Parsers::NumeralParser.new("glob is I I")
        expect(parser.condition).to eq false
      end

      it "should be throw false with 2 word translation" do
        parser = Parsers::NumeralParser.new("glob glob is I")
        expect(parser.condition).to eq false
      end
    end
    describe "process" do
      it "should create numeral object" do
        parser = Parsers::NumeralParser.new("glob is I")

        (numeral_obj, ledger, res) =  parser.process(nil, nil)

        res = {}
        res["glob"] = "I"

        expect(numeral_obj).to eq res
        expect(ledger).to eq ledger
      end

      it "should add to numeral object" do
        parser = Parsers::NumeralParser.new("glob is I")

        prev_obj = {}
        prev_obj["thing"] = "V"

        (numeral_obj, ledger, res) =  parser.process(prev_obj, nil)

        res = {}
        res["thing"] = "V"
        res["glob"] = "I"

        expect(numeral_obj).to eq res
        expect(ledger).to eq ledger
      end
    end
  end

  # "glob glob Silver is 34 Credits"
  context "RatioParser" do 
    describe "condition" do
      it "should be valid with proper format" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Credits")
        expect(parser.condition).to eq true
      end

      it "should be invalid non integer number of denomination" do
        parser = Parsers::RatioParser.new("glob glob Silver is poo Credits")
        expect(parser.condition).to eq false
      end

      it "should be invalid non more than 2 words in number and denomination" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Credits things")
        expect(parser.condition).to eq false
      end

      it "should be invalid with no words in trade" do
        parser = Parsers::RatioParser.new("is 0 Credits")
        expect(parser.condition).to eq false
      end

      it "should be valid with no number in trade" do
        parser = Parsers::RatioParser.new("Silver is 0 Credits")
        expect(parser.condition).to eq true
      end
    end
    describe "process" do
      it "should create ledger object" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Credits")

        prev_obj = {}
        prev_obj["glob"] = "I"

        (numeral_obj, ledger, res) =  parser.process(prev_obj, nil)

        res = {}
        res["Silver"] = {}
        res["Silver"]["Credits"] = 17

        expect(numeral_obj).to eq prev_obj
        expect(ledger).to eq res
      end

      it "should add to ledger object" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Credits")

        prev_obj = {}
        prev_obj["glob"] = "I"

        prev_ledger = {}
        prev_ledger["Gold"] = {}
        prev_ledger["Gold"]["Credits"] = 100

        (numeral_obj, ledger, res) =  parser.process(prev_obj, prev_ledger)

        res = {}
        res["Gold"] = {}
        res["Gold"]["Credits"] = 100
        res["Silver"] = {}
        res["Silver"]["Credits"] = 17

        expect(numeral_obj).to eq prev_obj
        expect(ledger).to eq res
      end

      it "should throw error if lexicon does not have value" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Credits")


        expect {(numeral_obj, ledger, res) =  parser.process({}, nil)}.to raise_error("there is no value glob")
      end

      it "should receive values other than Credits" do
        parser = Parsers::RatioParser.new("glob glob Silver is 34 Dollars")

        prev_obj = {}
        prev_obj["glob"] = "I"

        (numeral_obj, ledger, res) =  parser.process(prev_obj, nil)

        res = {}
        res["Silver"] = {}
        res["Silver"]["Dollars"] = 17

        expect(numeral_obj).to eq prev_obj
        expect(ledger).to eq res
      end
    end
  end

  context "CountParser" do 
    describe "condition" do
      it "should be valid with proper format" do
        parser = Parsers::CountParser.new("how much is pish tegj glob glob ?")
        expect(parser.condition).to eq true
      end

      it "should be invalid without ?" do
        parser = Parsers::CountParser.new("how much is pish tegj glob glob")
        expect(parser.condition).to eq false
      end

      it "should be invalid without 'how much'" do
        parser = Parsers::CountParser.new(" is pish tegj glob glob")
        expect(parser.condition).to eq false
      end
    end
    describe "process" do
      it "should tell you how much the tranlation is in roman numerals" do
        parser = Parsers::CountParser.new("how much is pish tegj glob glob")

        prev_obj = {}
        prev_obj["glob"] = "I"
        prev_obj["tegj"] = "V"
        prev_obj["pish"] = "X"

        (numeral_obj, ledger, res) =  parser.process(prev_obj, nil)

        expect(res).to eq "pish tegj glob glob is 17"
      end

      it "should work with 0" do
        parser = Parsers::CountParser.new("how much is ")

        prev_obj = {}
        prev_obj["glob"] = "I"
        prev_obj["tegj"] = "V"
        prev_obj["pish"] = "X"

        (numeral_obj, ledger, res) =  parser.process(prev_obj, nil)

        expect(res).to eq " is 0"
      end

      it "should throw if lexicon does not have mapping" do
        parser = Parsers::CountParser.new("how much is pish tegj glob glob")

        prev_obj = {}
        prev_obj["glob"] = "I"
        prev_obj["pish"] = "X"

        expect {(numeral_obj, ledger, res) =  parser.process(prev_obj, nil)}.to raise_error("there is no value tegj")
      end
    end
  end

  context "ValueParser" do 
    describe "condition" do
      it "should be valid with proper format" do
        parser = Parsers::ValueParser.new("how many Credits is glob prok Gold ?")
        expect(parser.condition).to eq true
      end

      it "should be invalid without ?" do
        parser = Parsers::ValueParser.new("how many Credits is glob prok Gold")
        expect(parser.condition).to eq false
      end

      it "should be invalid without 'how many'" do
        parser = Parsers::ValueParser.new("Credits is glob prok Gold")
        expect(parser.condition).to eq false
      end

      it "should have a denomination " do
        parser = Parsers::ValueParser.new("how many is glob prok Gold ?")
        expect(parser.condition).to eq false
      end

      it "should be valid wihout translation  numeral" do
        parser = Parsers::ValueParser.new("how many Credits is  Gold?")
        expect(parser.condition).to eq true
      end
    end
    describe "process" do
      it "should process denominations properly" do
        parser = Parsers::ValueParser.new("how many Dollars is glob glob Gold?")

        numeral_obj = {}
        numeral_obj["glob"] = "I"

        prev_ledger = {}
        prev_ledger["Gold"] = {}
        prev_ledger["Gold"]["Dollars"] = 100

        (numeral_obj, ledger, res) =  parser.process(numeral_obj, prev_ledger)

        expect(res).to eq "glob glob Gold is 200 Dollars"
      end

      it "should work when there is no translated numerals" do
        parser = Parsers::ValueParser.new("how many Dollars is  Gold?")

        numeral_obj = {}
        numeral_obj["glob"] = "I"

        prev_ledger = {}
        prev_ledger["Gold"] = {}
        prev_ledger["Gold"]["Dollars"] = 100

        (numeral_obj, ledger, res) =  parser.process(numeral_obj, prev_ledger)

        expect(res).to eq " Gold is 0 Dollars"
      end

      it "should throw when there is missing ledger data" do
        parser = Parsers::ValueParser.new("how many Dollars is glob glob Gold?")

        numeral_obj = {}
        numeral_obj["glob"] = "I"

        prev_ledger = {}
        prev_ledger["Gold"] = {}

        expect {parser.process(numeral_obj, prev_ledger)}.to raise_error("there is no value Gold,Dollars")
      end

      it "should throw when there is missing numeral data" do
        parser = Parsers::ValueParser.new("how many Dollars is glob glob Gold?")

        numeral_obj = {}

        prev_ledger = {}
        prev_ledger["Gold"] = {}
        prev_ledger["Gold"]["Dollars"] = 100

        expect {parser.process(numeral_obj, prev_ledger)}.to raise_error("there is no value glob")
      end
    end
  end
end