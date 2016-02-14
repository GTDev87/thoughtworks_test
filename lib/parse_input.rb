class ParseInput

  def initialize()
    @parsers = []
    @numeral_obj = nil
    @ledger = nil
  end

  def add_parser(parser)
    @parsers.push(parser)
  end

  def parse_line(line)
    begin
      parser = @parsers
        .map { |parser_class| parser_class.new(line) }
        .find { |parse| parse.condition() }

      if !parser then return "I have no idea what you are talking about" end

      (@numeral_obj, @ledger, res) = parser.process(@numeral_obj, @ledger)

      return res
    rescue
      return "I have no idea what you are talking about"
    end
  end

  def parse(lines)
    return lines.split("\n").map {|line| parse_line(line)}
      .select {|res| res}
  end
end