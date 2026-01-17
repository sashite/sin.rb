# frozen_string_literal: true

require_relative "sin/constants"
require_relative "sin/errors"
require_relative "sin/identifier"
require_relative "sin/parser"

module Sashite
  # SIN (Style Identifier Notation) implementation for Ruby.
  #
  # SIN provides a compact, ASCII-based format for encoding Player Style
  # with Player Side assignment in abstract strategy board games.
  #
  # A SIN token is exactly one ASCII letter:
  # - Uppercase (A-Z) indicates first player
  # - Lowercase (a-z) indicates second player
  #
  # @example Parsing SIN strings
  #   sin = Sashite::Sin.parse("C")
  #   sin.style  # => :C
  #   sin.side   # => :first
  #   sin.to_s   # => "C"
  #
  # @example Creating identifiers directly
  #   sin = Sashite::Sin::Identifier.new(:C, :first)
  #   sin.to_s  # => "C"
  #
  # @example Validation
  #   Sashite::Sin.valid?("C")   # => true
  #   Sashite::Sin.valid?("CC")  # => false
  #
  # @see https://sashite.dev/specs/sin/1.0.0/
  module Sin
    # Parses a SIN string into an Identifier.
    #
    # @param input [String] The SIN string to parse
    # @return [Identifier] The parsed identifier
    # @raise [Errors::Argument] If the input is invalid
    #
    # @example Parsing uppercase (first player)
    #   sin = Sashite::Sin.parse("C")
    #   sin.style  # => :C
    #   sin.side   # => :first
    #
    # @example Parsing lowercase (second player)
    #   sin = Sashite::Sin.parse("c")
    #   sin.style  # => :C
    #   sin.side   # => :second
    def self.parse(input)
      components = Parser.parse(input)

      Identifier.new(components.fetch(:style), components.fetch(:side))
    end

    # Reports whether the input is a valid SIN string.
    #
    # @param input [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Sin.valid?("C")   # => true
    #   Sashite::Sin.valid?("c")   # => true
    #   Sashite::Sin.valid?("")    # => false
    #   Sashite::Sin.valid?("CC")  # => false
    #   Sashite::Sin.valid?("1")   # => false
    def self.valid?(input)
      Parser.valid?(input)
    end
  end
end
