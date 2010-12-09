module Braindead
  class Choice < Rule
    def initialize(first, second)
      @first  = first.to_parser_rule
      @second = second.to_parser_rule
    end

    def parse(input, output)
      @first.parse(input, output) || @second.parse(input, output)
    end

    def parts
      [@first, @second]
    end

    def resolve_parts!(rules)
      @first  = @first.resolve(rules)
      @second = @second.resolve(rules)
    end
  end
end
