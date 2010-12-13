module Braindead
  class ZeroOrMore < Rule
    def initialize(rule)
      @rule = rule.to_parser_rule
    end

    def parse(input)
      results = success

      loop do
        result = @rule.parse(input)

        if result.success?
          results.concat(result)
        else
          break
        end
      end

      results
    end

    def parts
      [@rule]
    end

    def resolve_parts!(rules)
      @rule = @rule.resolve(rules)
    end
  end
end
