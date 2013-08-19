module Stacker
  class Command
    class Subtraction
      attr_reader :stack

      def initialize(stack)
        @stack = stack
      end

      def execute
        b, a = stack.pop, stack.pop
        value = a.value - b.value
        stack << Node::Number.new(value)
      end
    end
  end
end
