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
        Command.for(self, arg).execute
      end
    end
  end
end
