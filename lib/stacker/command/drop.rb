module Stacker
  module Command
    class Drop
      def execute(stack)
        stack.pop
      end
    end
  end
end
