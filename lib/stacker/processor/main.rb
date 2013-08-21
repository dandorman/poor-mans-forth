module Stacker
  module Processor
    class Main
      attr_reader :env

      def initialize(env = nil)
        @env = env || { previous: [], stack: [], procedures: {} }
      end

      def stack
        env[:stack]
      end

      def execute(arg)
        Command.for(arg).execute(stack)
        self.class.new(env)

      rescue Command::UnknownCommand
        case arg

        when *env[:procedures].keys
          new_processor = self.class.new(env)
          env[:procedures][arg].each do |command|
            new_processor = self.execute(command)
          end
          return new_processor

        when "IF"
          return Processor::IfElseBuilder.build(stack.pop, env.merge(previous: env[:previous] << self.class))

        when "TIMES"
          return Processor::Times.new(stack.pop.value, env.merge(previous: env[:previous] << self.class))

        when /\APROCEDURE\s+(.*)\z/
          return Processor::ProcedureDefinition.new($1, env.merge(previous: env[:previous] << self.class))

        when ":true"
          stack << Node::True.new
        when ":false"
          stack << Node::False.new
        when /\A:(.*)/
          stack << $1.to_sym
        when /\A\s*\z/
          # noop
        else
          stack << Node::Number.new(Integer(arg))
        end

        self.class.new(env)
      end
    end
  end
end
