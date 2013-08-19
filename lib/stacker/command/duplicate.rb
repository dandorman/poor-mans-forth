module Stacker
  class Command
    class Duplicate
      attr_reader :stack

      def initialize(stack)
        @stack = stack
      end

      def execute
        stack << stack.last
      end
    end
  end
end
