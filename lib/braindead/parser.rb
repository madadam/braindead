module Braindead
  class Parser
    def self.define(&block)
      new.tap { |parser| parser.instance_eval(&block) }
    end

    def initialize
      @rules = {}

      # Predefined rules
      @rules[:whitespace] = skip(zero_or_more(any_of(' ', "\t", "\n", "\v", "\f", "\r")))
    end

    attr_reader :rules

    def parse(input)
      resolve!

      root = rules[:root] or raise RuleNotDefined, "root rule not defined"

      input  = Cursor.new(input)
      output = []

      if root.parse(input, output)
        output.length > 1 ? output : output.first
      else
        raise Braindead::SyntaxError
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

    def skip(rule)
      Skip.new(rule)
    end

    def none
      None
    end

    def any_of(*tokens)
      satisfy { |token| tokens.include?(token) }
    end

    def any_except(*tokens)
      satisfy { |token| !tokens.include?(token) }
    end

    def eof
      Eof
    end

    def satisfy(&block)
      Satisfy.new(&block)
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
