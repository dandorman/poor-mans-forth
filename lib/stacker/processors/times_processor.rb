module Stacker
  class TimesProcessor
    def initialize(count, env, stack = [])
      @count = Integer(count)
      @env = env
      @stack = stack
    end

    def execute(arg)
      if arg == "/TIMES"
        processor = @env[:previous].pop.new(@env)
        @count.times do
          @stack.each do |arg|
            processor = processor.execute(arg)
          end
        end
        return processor
      else
        @stack << arg
      end

      self.class.new(@count, @env, @stack)
    end
  end
end
