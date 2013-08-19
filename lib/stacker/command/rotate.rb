module Stacker
  class Command
    class Rotate
      def execute(stack)
        last_three = stack.last(3)
        last_three << last_three.shift
        stack[-3..-1] = last_three
      end
    end
  end
end
