module Braindead
  class Transform < Rule
    def initialize(rule, &block)
      @rule  = rule.to_parser_rule
      @block = block
    end

    def parse(input)
      @rule.parse(input).if_success do |result|
        success(@block.call(*result.values))
      end
    end

    def parts
      [@rule]
    end

    def resolve_parts!(rules)
      @rule = @rule.resolve(rules)
    end

    def description
      @rule.description
    end
  end
end
