module Braindead
  class Choice < Rule
    def initialize(first, second)
      @first  = first.to_parser_rule
      @second = second.to_parser_rule
    end

    def parse(input)
      @first.parse(input).if_failure do |first|
        @second.parse(input).if_failure do |second|
          case
          when first.partial?  then first
          when second.partial? then second
          else                      Failure.new(input.position, description)
          end
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
      "#{@first.description} or #{@second.description}"
    end
  end
end
