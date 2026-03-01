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
  # All 52 valid identifiers are pre-instantiated and frozen at load time.
  # Every public method returns a cached instance — zero allocation on the
  # hot path.
  #
  # @example Parsing SIN strings
  #   sin = Sashite::Sin.parse("C")
  #   sin.abbr  # => :C
  #   sin.side  # => :first
  #   sin.to_s  # => "C"
  #
  # @example Safe parsing (no exceptions)
  #   Sashite::Sin.safe_parse("C")   # => #<Sashite::Sin::Identifier C>
  #   Sashite::Sin.safe_parse("1")   # => nil
  #   Sashite::Sin.safe_parse(nil)   # => nil
  #
  # @example Direct component lookup (fastest path)
  #   Sashite::Sin.fetch(:C, :first)  # => #<Sashite::Sin::Identifier C>
  #
  # @example Identity guarantee (flyweight)
  #   Sashite::Sin.parse("C").equal?(Sashite::Sin.fetch(:C, :first))  # => true
  #
  # @example Validation
  #   Sashite::Sin.valid?("C")   # => true
  #   Sashite::Sin.valid?("CC")  # => false
  #
  # @see https://sashite.dev/specs/sin/1.0.0/
  module Sin
    # Parses a SIN string into a cached Identifier.
    #
    # Returns a pre-instantiated, frozen instance.
    # Raises ArgumentError if the string is not valid.
    #
    # @param input [String] SIN string
    # @return [Identifier] A cached, frozen Identifier
    # @raise [Errors::Argument] If the input is invalid
    #
    # @example Parsing uppercase (first player)
    #   sin = Sashite::Sin.parse("C")
    #   sin.abbr  # => :C
    #   sin.side  # => :first
    #
    # @example Parsing lowercase (second player)
    #   sin = Sashite::Sin.parse("c")
    #   sin.abbr  # => :C
    #   sin.side  # => :second
    def self.parse(input)
      Parser.parse(input)
    end

    # Parses a SIN string without raising.
    #
    # Returns a cached Identifier on success, nil on failure.
    # Never allocates exception objects or captures backtraces.
    #
    # @param input [String] SIN string
    # @return [Identifier, nil] A cached Identifier, or nil if invalid
    #
    # @example
    #   Sashite::Sin.safe_parse("C")   # => #<Sashite::Sin::Identifier C>
    #   Sashite::Sin.safe_parse("")    # => nil
    #   Sashite::Sin.safe_parse(nil)   # => nil
    def self.safe_parse(input)
      Parser.safe_parse(input)
    end

    # Retrieves a cached Identifier by abbreviation and side.
    #
    # Bypasses string parsing entirely — direct hash lookup into the
    # flyweight pool. This is the fastest path for callers that already
    # have structured data.
    #
    # @param abbr [Symbol] Style abbreviation (:A through :Z)
    # @param side [Symbol] Player side (:first or :second)
    # @return [Identifier] A cached, frozen Identifier
    # @raise [Errors::Argument] If components are invalid
    #
    # @example
    #   Sashite::Sin.fetch(:C, :first)   # => #<Sashite::Sin::Identifier C>
    #   Sashite::Sin.fetch(:C, :second)  # => #<Sashite::Sin::Identifier c>
    def self.fetch(abbr, side)
      Identifier::POOL.fetch([abbr, side]) do
        if !Identifier::VALID_ABBRS.include?(abbr)
          raise Errors::Argument, Errors::Argument::Messages::INVALID_ABBR
        else
          raise Errors::Argument, Errors::Argument::Messages::INVALID_SIDE
        end
      end
    end

    # Reports whether string is a valid SIN identifier.
    #
    # Never raises; returns false for any invalid input including non-String.
    # Uses an exception-free code path internally for performance.
    #
    # @param input [String] SIN string
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Sin.valid?("C")   # => true
    #   Sashite::Sin.valid?("c")   # => true
    #   Sashite::Sin.valid?("")    # => false
    #   Sashite::Sin.valid?("CC")  # => false
    #   Sashite::Sin.valid?("1")   # => false
    #   Sashite::Sin.valid?(nil)   # => false
    def self.valid?(input)
      Parser.valid?(input)
    end
  end
end
