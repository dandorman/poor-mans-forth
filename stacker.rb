module Stacker
  class Interpreter
    def initialize
      @processor = Processor.new
    end

    def stack
      @processor.stack
    end

    def execute(arg)
      @processor = @processor.execute(arg)
    end
  end

  class Processor
    OPERATIONS = {
      "ADD"      => :+,
      "SUBTRACT" => :-,
      "MULTIPLY" => :*,
      "DIVIDE"   => :/,
      "MOD"      => :%,
      "<"        => :<,
      ">"        => :>,
      "="        => :==
    }

    attr_accessor :stack

    def initialize(contexts = [[]])
      @contexts = contexts
      @stack = if @contexts.last.is_a?(Array)
                 @contexts.last
               elsif @contexts.last[:else]
                 @contexts.last[:else]
               else
                 @contexts.last[:if]
               end
    end

    def execute(arg)
      case arg

      when *OPERATIONS.keys
        b, a = stack.pop, stack.pop
        self.stack << process_result(a.send(OPERATIONS[arg], b))

      when "IF"
        if_else = {
          test: stack.pop,
          if: [],
          else: nil
        }
        @contexts << if_else
        self.stack = @contexts.last[:if]
      when "ELSE"
        @contexts.last[:else] = []
        self.stack = @contexts.last[:else]
      when "THEN"
        if_else = @contexts.pop
        if @contexts.last.is_a?(Array)
          self.stack = @contexts.last
        elsif @contexts.last[:else]
          self.stack = @contexts.last[:else]
        else
          self.stack = @contexts.last[:if]
        end

        if if_else[:test] == :true
          stack.concat(if_else[:if])
        else
          stack.concat(if_else[:else])
        end

      when ":true"
        stack << :true
      when ":false"
        stack << :false
      else
        stack << arg.to_i
      end

      self.class.new(@contexts)
    end

    private

    def process_result(result)
      case result
      when true, false
        result.to_s.to_sym
      else
        result
      end
    end
  end
end
