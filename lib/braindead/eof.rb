module Braindead
  class << Eof = Rule.new
    def parse(input, output)
      input.end?
    end
  end
end
