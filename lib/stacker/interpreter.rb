module Stacker
  class Interpreter
    def initialize
      @processor = Processor::Main.new
    end

    def stack
      @processor.stack.map { |value|
        case value
        when TrueClass, FalseClass
          value.to_s.to_sym
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
