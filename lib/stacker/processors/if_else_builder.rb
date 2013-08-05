module Stacker
  class IfElseBuilder
    def self.build(test, env)
      test ? IfProcessor.new(env) : EmptyIfProcessor.new(env)
    end
  end
end
