module Stacker
  class ElseProcessor < Processor
    def execute(arg)
      return super unless arg == "THEN"
      env[:previous].pop.new(env)
    end
  end
end
