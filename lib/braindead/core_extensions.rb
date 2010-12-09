module Braindead
  module Operators
    def >>(other)
      to_parser_rule >> other
    end

    def /(other)
      to_parser_rule / other
    end
  end
end

class Range
  include Braindead::Operators

  def to_parser_rule
    Braindead::Range.new(self.begin, self.end)
  end
end

class String
  include Braindead::Operators

  def to_parser_rule
    Braindead::String.new(self)
  end
end

class Symbol
  include Braindead::Operators

  def to_parser_rule
    Braindead::Reference.new(self)
  end
end
