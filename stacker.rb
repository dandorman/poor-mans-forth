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

    attr_reader :stack

    def initialize
      @stack = []
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << process_result(a.send(OPERATIONS[arg], b))

      when "IF"
        return IfElseProcessor.build(stack.pop == :true, self)

      when ":true"
        stack << :true
      when ":false"
        stack << :false
      else
        stack << Integer(arg)
      end

      self
    end

    def concat(other_stack)
      other_stack.each do |arg|
        execute arg
      end
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

  class IfElseProcessor
    def self.build(test, previous)
      test ? IfProcessor.new(previous) : EmptyIfProcessor.new(previous)
    end
  end

  class IfProcessor
    attr_reader :stack
    attr_reader :previous

    def initialize(previous)
      @previous = previous
      @stack = []
    end

    def execute(arg)
      case arg

      when "IF"
        return IfElseProcessor.build(stack.pop == :true, self)
      when "ELSE"
        previous.concat(stack)
        return EmptyElseProcessor.new(previous)

      else
        stack << arg
      end

      self
    end

    def concat(other_stack)
      stack.concat(other_stack)
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

  class ElseProcessor
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

    attr_reader :stack
    attr_reader :previous

    def initialize(previous)
      @previous = previous
      @stack = []
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << process_result(a.send(OPERATIONS[arg], b))

      when "IF"
        return IfElseProcessor.build(stack.pop == :true, self)
      when "THEN"
        previous.concat(stack)
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

    def concat(other_stack)
      stack.concat(other_stack)
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
