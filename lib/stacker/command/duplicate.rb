module Stacker
  class Command
    class Duplicate
      def execute(stack)
        stack << stack.last
      end
    end
  end
end
