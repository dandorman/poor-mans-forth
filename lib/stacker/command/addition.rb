module Stacker
  class Command
    class Addition
      def execute(stack)
        b, a = stack.pop, stack.pop
        value = a.value + b.value
        stack << Node::Number.new(value)
      end
    end
  end
end
