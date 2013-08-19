module Stacker
  class Command
    class EqualTo
      attr_reader :stack

      def initialize(stack)
        @stack = stack
      end

      def execute
        b, a = stack.pop, stack.pop
        value = a.value == b.value
        stack << value
      end
    end
  end
end
