module Stacker
  class Command
    class Swap
      attr_reader :stack

      def initialize(stack)
        @stack = stack
      end

      def execute
        stack[-2..-1] = stack[-2..-1].reverse
      end
    end
  end
end
