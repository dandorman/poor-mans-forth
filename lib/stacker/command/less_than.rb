module Stacker
  module Command
    class LessThan
      def execute(stack)
        b, a = stack.pop, stack.pop
        value = a.value < b.value
        stack << (value ? Node::True.new : Node::False.new)
      end
    end
  end
end
