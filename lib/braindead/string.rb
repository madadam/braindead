module Braindead
  class String < Rule
    def initialize(string)
      @string = string
    end

    def parse(input)
      if input.peek(@string.length) == @string
        input.advance!(@string.length)

        success(@string)
      else
        failure(input)
      end
    end

    def description
      @string.inspect
    end
  end
end
