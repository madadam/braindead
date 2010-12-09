module Braindead
  class Rule
    def >>(other)
      Sequence.new(self, other)
    end

    def /(other)
      Choice.new(self, other)
    end

    def to_parser_rule
      self
    end

    def resolve_parts!(rules)
    end

    def resolve(rules)
      self
    end

    def parts
      []
    end

    private

    def success(output, *results)
      results.each { |result| output << result }
      true
    end

    def failure
      false
    end
  end
end
