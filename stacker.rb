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
      when "ELSE"
        previous.stack.concat(stack)
        return EmptyElseProcessor.new(previous)

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

  class EmptyIfProcessor
    attr_reader :depth
    attr_reader :previous

    def initialize(previous)
      @depth = 0
      @previous = previous
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "ELSE"
        return ElseProcessor.new(previous) if depth.zero?
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

    attr_accessor :stack
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
        previous.stack.concat(stack)
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

  class EmptyElseProcessor
    attr_reader :depth
    attr_reader :previous

    def initialize(previous)
      @depth = 0
      @previous = previous
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "THEN"
        if depth.zero?
          return previous
        else
          @depth -= 1
        end
      end

      self
    end
  end
end
