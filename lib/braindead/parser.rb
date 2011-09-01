module Braindead
  class Parser
    def self.define(&block)
      new.tap { |parser| parser.instance_eval(&block) }
    end

    def initialize
      @rules = {}

      # Predefined rules
      @rules[:whitespace] = skip(zero_or_more(one_of(' ', "\t", "\n", "\v", "\f", "\r")))
    end

    attr_reader :rules

    def parse(string)
      resolve!

      root   = rules[:root] or raise RuleNotDefined, "root rule not defined"
      input  = Input.new(string)
      result = root.parse(input)

      if result.success?
        result.value
      else
        raise Braindead::SyntaxError.new(result.position, result.description, string)
      end
    end

    def root(content, *args, &block)
      rule(:root, content, *args, &block)
    end

    def rule(name, content, *args, &block)
      raise RuleAlreadyDefined, "rule '#{name}' is already defined" if rules.has_key?(name)

      rule = content.to_parser_rule
      rule = transform(rule, *args, &block)

      @modified = true
      @rules[name] = rule
    end

    def action(name, *args, &block)
      rules[name] = transform(rules[name] || name, *args, &block)
    end

    # Combinators

    def zero_or_more(rule)
      ZeroOrMore.new(rule)
    end

    def zero_or_more_with_separator(stuff, separator)
      (stuff >> zero_or_more(skip(separator) >> stuff)) / none
    end

    def one_or_more(rule)
      rule >> zero_or_more(rule)
    end

    def skip(rule)
      Skip.new(rule)
    end

    def none
      None
    end

    def one_of(*tokens)
      description = "one of [#{tokens.map(&:inspect).join(', ')}]"
      satisfy(description) { |token| tokens.include?(token) }
    end

    def none_of(*tokens)
      description = "none of [#{tokens.map(&:inspect).join(', ')}]"
      satisfy(description) { |token| !tokens.include?(token) }
    end

    def eof
      Eof
    end

    def satisfy(description = nil, &block)
      Satisfy.new(description, &block)
    end

    def transform(rule, *args, &block)
      rule = Transform.new(rule) { args.first } unless args.empty?
      rule = Transform.new(rule, &block) if block
      rule
    end

    def token(pattern, *args)
      rule = pattern >> skip(:whitespace)
      args.empty? ? skip(rule) : transform(rule, *args)
    end

    private

    def resolve!
      if @modified
        rules[:root] = rules[:root].resolve(rules)

        GraphWalker.walk(rules[:root]) { |rule| rule.resolve_parts!(rules) }
        @modified = false
      end
    end
  end
end
