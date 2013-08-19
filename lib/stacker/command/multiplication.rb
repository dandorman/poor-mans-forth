module Stacker
  module Command
    class Multiplication
      def execute(stack)
        b, a = stack.pop, stack.pop
        value = a.value * b.value
        stack << Node::Number.new(value)
      end
    end
  end
end
