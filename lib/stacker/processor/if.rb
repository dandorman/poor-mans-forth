module Stacker
  module Processor
    class If < Main
      def execute(arg)
        return super unless arg == "ELSE"
        EmptyElse.new(env)
      end
    end
  end
end
