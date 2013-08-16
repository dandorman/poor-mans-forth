module Stacker
  module Processor
    class ProcedureDefinition
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
end
