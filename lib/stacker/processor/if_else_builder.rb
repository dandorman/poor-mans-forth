module Stacker
  module Processor
    class IfElseBuilder
      def self.build(test, env)
        test ? If.new(env) : EmptyIf.new(env)
      end
    end
  end
end
