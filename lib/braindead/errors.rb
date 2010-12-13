module Braindead
  Error               = Class.new(RuntimeError)
  RuleAlreadyDefined  = Class.new(Error)
  RuleNotDefined      = Class.new(Error)
  UnresolvedReference = Class.new(Error)

  class SyntaxError < Error
    def initialize(position, expectation, input)
      @position    = position
      @expectation = expectation
      @input       = input
    end

    attr_reader :position
    attr_reader :expectation

    def message
      "unexpected #{excerpt.inspect} at position #{position}, expecting #{expectation}"
    end

    def excerpt(window = 20)
      excerpt = @input[position, window]
      excerpt += ' ...' if @input.length - position > window
      excerpt
    end
  end
end
