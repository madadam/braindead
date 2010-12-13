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

    def success(*values)
      Success.new(*values)
    end

    def failure(input)
      Failure.new(input.position, description)
    end
  end
end
