module Braindead
  class Skip < Rule

    # Prevent skipping skips.
    def self.new(rule)
      rule.is_a?(self) ? rule : super
    end

    def initialize(rule)
      @rule = rule.to_parser_rule
    end

    def parse(input, output)
      @rule.parse(input, [])
    end

    def parts
      [@rule]
    end

    def resolve_parts!(rules)
      @rule = @rule.resolve(rules)
    end
  end
end
