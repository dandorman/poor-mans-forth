module Stacker
  module Node
    class Number
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_s
        @value.to_s
      end
    end
  end
end
