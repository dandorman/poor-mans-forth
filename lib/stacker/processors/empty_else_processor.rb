module Stacker
  class EmptyElseProcessor
    def initialize(env, depth = 0)
      @depth = depth
      @env = env
    end

    def execute(arg)
      case arg
      when "IF"
        @depth += 1
      when "THEN"
        if @depth.zero?
          return @env[:previous].pop.new(@env)
        else
          @depth -= 1
        end
      end

      self.class.new(@env, @depth)
    end
  end
end
