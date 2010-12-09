module Braindead
  class Cursor
    def initialize(input, position = 0)
      @input    = input
      @position = position
    end

    attr_accessor :position

    def [](*args)
      case args.size
      when 2
        @input[position + args[0], args[1]]
      when 1
        @input[position + args[0]]
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1 or 2)"
      end
    end

    def end?
      position >= @input.length
    end

    def remaining
      @input[position .. -1]
    end
  end
end
