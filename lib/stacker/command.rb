require_relative 'command/addition'
require_relative 'command/subtraction'
require_relative 'command/multiplication'
require_relative 'command/division'
require_relative 'command/modulo'

require_relative 'command/less_than'
require_relative 'command/greater_than'
require_relative 'command/equal_to'

require_relative 'command/duplicate'
require_relative 'command/swap'
require_relative 'command/drop'
require_relative 'command/rotate'

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
      "DUP"      => Duplicate,
      "SWAP"     => Swap,
      "DROP"     => Drop,
      "ROT"      => Rotate,
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
