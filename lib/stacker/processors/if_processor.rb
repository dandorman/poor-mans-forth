module Stacker
  class IfProcessor < Processor
    def execute(arg)
      return super unless arg == "ELSE"
      EmptyElseProcessor.new(env)
    end
  end
end
