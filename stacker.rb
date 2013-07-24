module Stacker
  class Interpreter
    def initialize
      @processor = Processor.new
    end

    def stack
      @processor.stack.map { |value|
        case value
        when TrueClass, FalseClass
          value.to_s.to_sym
        else
          value
        end
      }
    end

    def execute(arg)
      @processor = @processor.execute(arg)
    end
  end

  class Processor
    OPERATIONS = {
      "ADD"      => :+,
      "SUBTRACT" => :-,
      "MULTIPLY" => :*,
      "DIVIDE"   => :/,
      "MOD"      => :%,
      "<"        => :<,
      ">"        => :>,
      "="        => :==
    }

    attr_reader :previous
    attr_reader :stack

    def initialize(previous = nil)
      @previous = previous
      @stack = []
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << a.send(OPERATIONS[arg], b)

      when "IF"
        return IfElseBuilder.build(stack.pop, self)

      when ":true"
        stack << true
      when ":false"
        stack << false
      else
        stack << Integer(arg)
      end

      self
    end
  end

  class IfElseBuilder
    def self.build(test, previous)
      test ? IfProcessor.new(previous) : EmptyIfProcessor.new(previous)
    end
  end

  class IfProcessor < Processor
    def execute(arg)
      return super unless arg == "ELSE"

      previous.stack.concat(stack)
      EmptyElseProcessor.new(previous)
    end
  end

  class EmptyIfProcessor
    def initialize(previous)
      @depth = 0
      @previous = previous
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "ELSE"
        return ElseProcessor.new(@previous) if @depth.zero?
      when "THEN"
        @depth -= 1
      end

      self
    end
  end

  class ElseProcessor < Processor
    def execute(arg)
      return super unless arg == "THEN"

      previous.stack.concat(stack)
      previous
    end
  end

  class EmptyElseProcessor
    def initialize(previous)
      @depth = 0
      @previous = previous
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "THEN"
        if @depth.zero?
          return @previous
        else
          @depth -= 1
        end
      end

      self
    end
  end
end
