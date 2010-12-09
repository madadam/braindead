module Braindead
  class Range < Rule
    def initialize(first, last)
      @first = first
      @last  = last
    end

    def parse(input, output)
      token = input[0]

      if token && token >= @first && token <= @last
        input.position += 1
        success(output, token)
      else
        failure
      end
    end
  end
end
