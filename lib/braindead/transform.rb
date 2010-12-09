module Braindead
  class Transform < Rule
    def initialize(rule, &block)
      @rule  = rule.to_parser_rule
      @block = block
    end

    def parse(input, output)
      temp_output = []

      if @rule.parse(input, temp_output)
        success(output, @block.call(*temp_output))
      else
        failure
      end
    end

    def parts
      [@rule]
    end

    def resolve_parts!(rules)
      @rule = @rule.resolve(rules)
    end
  end
end
