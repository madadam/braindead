module Braindead
  class << Eof = Rule.new
    def parse(input)
      input.end? ? success : failure(input)
    end

    def description
      'end of file'
    end
  end
end
