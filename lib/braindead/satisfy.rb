module Braindead
  class Satisfy < Rule
    def initialize(&block)
      @block = block
    end

    def parse(input, output)
      token = input[0]

      if @block.call(token)
        input.position += 1
        success(output, token)
      else
        failure
      end
    end
  end
end
