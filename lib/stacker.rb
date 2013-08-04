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

    attr_reader :env

    def initialize(env = nil)
      @env = env || { previous: [], stack: [], procedures: {} }
    end

    def stack
      env[:stack]
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        stack << a.send(OPERATIONS[arg], b)

      when *env[:procedures].keys
        processor = self.class.new(env)
        env[:procedures][arg].each do |command|
          processor = processor.execute(command)
        end
        return processor

      when "DUP"
        stack << stack.last
      when "SWAP"
        stack[-2..-1] = stack[-2..-1].reverse
      when "DROP"
        stack.pop
      when "ROT"
        last_three = stack.last(3)
        last_three << last_three.shift
        stack[-3..-1] = last_three

      when "IF"
        return IfElseBuilder.build(stack.pop, env.merge(previous: env[:previous] << self.class))

      when "TIMES"
        return TimesProcessor.new(stack.pop, env.merge(previous: env[:previous] << self.class))

      when /\APROCEDURE\s+(.*)\z/
        return ProcedureDefinitionProcessor.new($1, env.merge(previous: env[:previous] << self.class))

      when ":true"
        stack << true
      when ":false"
        stack << false
      when /\A:(.*)/
        stack << $1.to_sym
      when /\A\s*\z/
        # noop
      else
        stack << Integer(arg)
      end

      self.class.new(env)
    end
  end

  class IfElseBuilder
    def self.build(test, env)
      test ? IfProcessor.new(env) : EmptyIfProcessor.new(env)
    end
  end

  class IfProcessor < Processor
    def execute(arg)
      return super unless arg == "ELSE"
      EmptyElseProcessor.new(env)
    end
  end

  class EmptyIfProcessor
    def initialize(env, depth = 0)
      @depth = depth
      @env = env
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "ELSE"
        return ElseProcessor.new(@env) if @depth.zero?
      when "THEN"
        @depth -= 1
      end

      self.class.new(@env, @depth)
    end
  end

  class ElseProcessor < Processor
    def execute(arg)
      return super unless arg == "THEN"
      env[:previous].pop.new(env)
    end
  end

  class EmptyElseProcessor
    def initialize(env, depth = 0)
      @depth = depth
      @env = env
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "THEN"
        if @depth.zero?
          return @env[:previous].pop.new(@env)
        else
          @depth -= 1
        end
      end

      self.class.new(@env, @depth)
    end
  end

  class TimesProcessor
    def initialize(count, env, stack = [])
      @count = Integer(count)
      @env = env
      @stack = stack
    end

    def execute(arg)
      if arg == "/TIMES"
        processor = @env[:previous].pop.new(@env)
        @count.times do
          @stack.each do |arg|
            processor = processor.execute(arg)
          end
        end
        return processor
      else
        @stack << arg
      end

      self.class.new(@count, @env, @stack)
    end
  end

  class ProcedureDefinitionProcessor
    def initialize(name, env, stack = [])
      @name = name
      @env = env
      @stack = stack
    end

    def execute(arg)
      if arg == "/PROCEDURE"
        @env[:procedures][@name] = @stack
        @env[:previous].pop.new(@env)
      else
        @stack << arg
        self.class.new(@name, @env, @stack)
      end
    end
  end
end
