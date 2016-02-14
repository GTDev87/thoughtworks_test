require File.expand_path("../parse_input", __FILE__)
require File.expand_path("../parsers", __FILE__)

file = File.open(ARGV[0], "rb")
contents = file.read

parse_input = ParseInput.new

parse_input.add_parser(Parsers::NumeralParser)
parse_input.add_parser(Parsers::RatioParser)
parse_input.add_parser(Parsers::CountParser)
parse_input.add_parser(Parsers::ValueParser)

results = parse_input.parse(contents).join("\n")
print results