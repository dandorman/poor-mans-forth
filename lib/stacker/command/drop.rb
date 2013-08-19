module Stacker
  class Command
    class Drop
      attr_reader :stack

      def initialize(stack)
        @stack = stack
      end

      def execute
        stack.pop
      end
    end
  end
end
