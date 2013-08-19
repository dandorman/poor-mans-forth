module Stacker
  module Command
    class LessThan
      def execute(stack)
        b, a = stack.pop, stack.pop
        value = a.value < b.value
        stack << value
      end
    end
  end
end
