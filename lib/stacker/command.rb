require_relative 'command/addition'
require_relative 'command/subtraction'
require_relative 'command/multiplication'
require_relative 'command/division'
require_relative 'command/modulo'

require_relative 'command/less_than'
require_relative 'command/greater_than'
require_relative 'command/equal_to'

module Stacker
  class Command
    OPERATIONS = {
      "ADD"      => Addition,
      "SUBTRACT" => Subtraction,
      "MULTIPLY" => Multiplication,
      "DIVIDE"   => Division,
      "MOD"      => Modulo,
      "<"        => LessThan,
      ">"        => GreaterThan,
      "="        => EqualTo,
    }

    def self.for(processor, arg)
      new(processor, arg)
    end

    attr_reader :processor, :arg

    def initialize(processor, arg)
      @processor, @arg = processor, arg
    end

    def execute
      case arg

      when *OPERATIONS.keys
        OPERATIONS.fetch(arg).new(processor.stack).execute

      when *env[:procedures].keys
        new_processor = processor.class.new(env)
        env[:procedures][arg].each do |command|
          new_processor = new_processor.execute(command)
        end
        return new_processor

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
        return Processor::IfElseBuilder.build(stack.pop, env.merge(previous: env[:previous] << processor.class))

      when "TIMES"
        return Processor::Times.new(stack.pop.value, env.merge(previous: env[:previous] << processor.class))

      when /\APROCEDURE\s+(.*)\z/
        return Processor::ProcedureDefinition.new($1, env.merge(previous: env[:previous] << processor.class))

      when ":true"
        stack << true
      when ":false"
        stack << false
      when /\A:(.*)/
        stack << $1.to_sym
      when /\A\s*\z/
        # noop
      else
        stack << Node::Number.new(Integer(arg))
      end

      processor.class.new(env)
    end

    private

    def stack
      processor.stack
    end

    def env
      processor.env
    end
  end
end
