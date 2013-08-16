module Stacker
  module Processor
    class EmptyIf
      def initialize(env, depth = 0)
        @depth = depth
        @env = env
      end

      def execute(arg)
        case arg
        when "IF"
          @depth += 1
        when "ELSE"
          return Else.new(@env) if @depth.zero?
        when "THEN"
          @depth -= 1
        end

        self.class.new(@env, @depth)
      end
    end
  end
end
