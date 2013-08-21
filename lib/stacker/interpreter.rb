module Stacker
  class Interpreter
    def initialize
      @processor = Processor::Main.new
    end

    def stack
      @processor.stack.map { |value|
        case value
        when Node::True
          :true
        when Node::False
          :false
        when Node::Number
          value.value
        else
          value
        end
      }
    end

    def execute(arg)
      @processor = @processor.execute(arg)
    end
  end
end
