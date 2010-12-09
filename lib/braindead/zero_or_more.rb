module Braindead
  class ZeroOrMore < Rule
    def initialize(rule)
      @rule = rule.to_parser_rule
    end

    def parse(input, output)
      loop { break unless @rule.parse(input, output) }

      true
    end

    def parts
      [@rule]
    end

    def resolve_parts!(rules)
      @rule = @rule.resolve(rules)
    end
  end
end
