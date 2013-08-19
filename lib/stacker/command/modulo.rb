module Stacker
  module Command
    class Modulo
      def execute(stack)
        b, a = stack.pop, stack.pop
        value = a.value % b.value
        stack << Node::Number.new(value)
      end
    end
  end
end
