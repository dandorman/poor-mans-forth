module Stacker
  module Command
    class Duplicate
      def execute(stack)
        stack << stack.last
      end
    end
  end
end
