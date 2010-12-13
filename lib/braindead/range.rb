module Braindead
  class Range < Rule
    def initialize(first, last)
      @first = first
      @last  = last
    end

    def parse(input)
      token = input.peek

      if token && token >= @first && token <= @last
        input.advance!
        success(token)
      else
        failure(input)
      end
    end

    def description
      "#{@first.inspect} .. #{@last.inspect}"
    end
  end
end
