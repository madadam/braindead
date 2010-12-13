module Braindead
  class Satisfy < Rule
    def initialize(description = nil, &block)
      @description = description
      @block       = block
    end

    def parse(input)
      token = input.peek

      if @block.call(token)
        input.advance!
        success(token)
      else
        failure(input)
      end
    end

    attr_reader :description
  end
end
