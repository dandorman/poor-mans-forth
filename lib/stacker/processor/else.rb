module Stacker
  module Processor
    class Else < Main
      def execute(arg)
        return super unless arg == "THEN"
        env[:previous].pop.new(env)
      end
    end
  end
end
