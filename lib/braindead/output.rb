module Braindead
  class Success
    def initialize(*values)
      @values = values
    end

    attr_reader :values

    def value
      @values.length > 1 ? @values : @values.first
    end

    def concat(other)
      @values.concat(other.values)
      self
    end

    def success?
      true
    end

    def failure?
      false
    end

    def if_success
      yield(self)
    end

    def if_failure
      self
    end
  end

  class Failure
    def initialize(position, description)
      @position    = position
      @description = description
      @partial     = false
    end

    attr_reader :position
    attr_reader :description
    attr_writer :partial

    def partial?
      @partial
    end

    def success?
      false
    end

    def failure?
      true
    end

    def if_success
      self
    end

    def if_failure
      yield(self)
    end
  end
end
