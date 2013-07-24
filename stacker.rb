module Stacker
  class Interpreter
    def initialize
      @processor = Processor.new
    end

    def stack
      @processor.stack
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

    attr_accessor :stack

    def initialize
      @stack = []
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << process_result(a.send(OPERATIONS[arg], b))

      when "IF"
        return IfProcessor.new(stack.pop == :true, self)

      when ":true"
        stack << :true
      when ":false"
        stack << :false
      else
        stack << Integer(arg)
      end

      self
    end

    private

    def process_result(result)
      case result
      when true, false
        result.to_s.to_sym
      else
        result
      end
    end
  end

  class IfProcessor
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

    attr_accessor :stack
    attr_reader :if_stack
    attr_reader :else_stack
    attr_reader :previous
    attr_reader :test

    def initialize(test, previous)
      @test = test
      @previous = previous
      @stack = @if_stack = []
      @else_stack = []
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << process_result(a.send(OPERATIONS[arg], b))

      when "IF"
        return IfProcessor.new(stack.pop == :true, self)
      when "ELSE"
        self.stack = else_stack
      when "THEN"
        if test
          previous.stack.concat(if_stack)
        else
          previous.stack.concat(else_stack)
        end
        return previous

      when ":true"
        stack << :true
      when ":false"
        stack << :false
      else
        stack << Integer(arg)
      end

      self
    end

    private

    def process_result(result)
      case result
      when true, false
        result.to_s.to_sym
      else
        result
      end
    end
  end
end
