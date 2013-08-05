module Stacker
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
end
