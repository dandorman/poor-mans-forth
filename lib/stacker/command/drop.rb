module Stacker
  class Command
    class Drop
      def execute(stack)
        stack.pop
      end
    end
  end
end
