module Stacker
  class Command
    class Swap
      def execute(stack)
        stack[-2..-1] = stack[-2..-1].reverse
      end
    end
  end
end
