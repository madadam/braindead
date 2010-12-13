module Braindead
  class Input
    def initialize(data, position = 0)
      @data     = data
      @position = position
    end

    attr_accessor :position

    def advance!(offset = 1)
      self.position += offset
    end

    def peek(length = 1)
      @data[position, length]
    end

    def end?
      position >= @data.length
    end
  end
end
