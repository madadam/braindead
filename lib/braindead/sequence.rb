module Braindead
  class Sequence < Rule
    def initialize(first, second)
      @first  = first.to_parser_rule
      @second = second.to_parser_rule
    end

    def parse(input, output)
      input_position = input.position
      output_length  = output.length

      if @first.parse(input, output) && @second.parse(input, output)
        success(output)
      else
        input.position = input_position
        output.slice!(output_length .. -1)
        failure
      end
    end

    def parts
      [@first, @second]
    end

    def resolve_parts!(rules)
      @first  = @first.resolve(rules)
      @second = @second.resolve(rules)
    end
  end
end
