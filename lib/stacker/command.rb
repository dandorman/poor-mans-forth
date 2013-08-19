require_relative 'command/addition'
require_relative 'command/subtraction'
require_relative 'command/multiplication'
require_relative 'command/division'
require_relative 'command/modulo'

require_relative 'command/less_than'
require_relative 'command/greater_than'
require_relative 'command/equal_to'

require_relative 'command/duplicate'
require_relative 'command/swap'
require_relative 'command/drop'
require_relative 'command/rotate'

module Stacker
  module Command
    OPERATIONS = {
      "ADD"      => Addition,
      "SUBTRACT" => Subtraction,
      "MULTIPLY" => Multiplication,
      "DIVIDE"   => Division,
      "MOD"      => Modulo,
      "<"        => LessThan,
      ">"        => GreaterThan,
      "="        => EqualTo,
      "DUP"      => Duplicate,
      "SWAP"     => Swap,
      "DROP"     => Drop,
      "ROT"      => Rotate,
    }

    UnknownCommand = Class.new(StandardError)

    def self.for(arg)
      OPERATIONS.fetch(arg).new
    rescue KeyError
      raise UnknownCommand, arg
    end
  end
end
