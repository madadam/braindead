module Braindead
  class Sequence < Rule
    def initialize(first, second)
      @first  = first.to_parser_rule
      @second = second.to_parser_rule
    end

    def parse(input)
      position = input.position

      @first.parse(input).if_success do |first|
        second = @second.parse(input)

        if second.success?
          first.concat(second)
        else
          input.position = position

          second.partial = true
          second
        end
      end
    end

    def parts
      [@first, @second]
    end

    def resolve_parts!(rules)
      @first  = @first.resolve(rules)
      @second = @second.resolve(rules)
    end

    def description
      @first.description
    end
  end
end
