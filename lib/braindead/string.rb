module Braindead
  class String < Rule
    def initialize(string)
      @string = string
    end

    def parse(input, output)
      if input[0, @string.length] == @string
        input.position += @string.length
        output << @string
        true
      else
        false
      end
    end
  end
end
