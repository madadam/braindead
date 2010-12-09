module Braindead
  class Reference < Rule
    def initialize(name)
      @name = name
    end

    def parse(input, output)
      raise UnresolvedReference, "reference to '#{@name}' is not resolved"
    end

    def resolve(rules)
      rule = rules[@name] or raise RuleNotDefined, "rule '#{@name}' is not defined"
      rule.resolve(rules)
    end
  end
end
