# frozen_string_literal: true

require_relative "constants"
require_relative "errors"

module Sashite
  module Sin
    # Represents a parsed SIN (Style Identifier Notation) identifier.
    #
    # An Identifier encodes two attributes:
    # - Abbr: the style abbreviation (A-Z as uppercase symbol)
    # - Side: the player side (:first or :second)
    #
    # All 52 possible instances are pre-instantiated and frozen at load time.
    # Never construct directly — use {Sashite::Sin.parse}, {Sashite::Sin.safe_parse},
    # or {Sashite::Sin.fetch} instead.
    #
    # @example Obtaining identifiers
    #   Sashite::Sin.parse("C")           # => #<Sashite::Sin::Identifier C>
    #   Sashite::Sin.fetch(:C, :first)    # => #<Sashite::Sin::Identifier C>
    #
    # @example Identity guarantee (flyweight)
    #   Sashite::Sin.parse("C").equal?(Sashite::Sin.fetch(:C, :first))  # => true
    #
    # @see https://sashite.dev/specs/sin/1.0.0/
    class Identifier
      # Valid abbreviation symbols (A-Z).
      VALID_ABBRS = Constants::VALID_ABBRS

      # Valid side symbols.
      VALID_SIDES = Constants::VALID_SIDES

      # @return [Symbol] Style abbreviation (:A to :Z, always uppercase)
      attr_reader :abbr

      # @return [Symbol] Player side (:first or :second)
      attr_reader :side

      # Creates a new Identifier instance.
      #
      # @param abbr [Symbol] Style abbreviation (:A to :Z)
      # @param side [Symbol] Player side (:first or :second)
      # @return [Identifier] A new frozen Identifier instance
      # @raise [Errors::Argument] If any attribute is invalid
      #
      # @api private
      def initialize(abbr, side)
        validate_abbr!(abbr)
        validate_side!(side)

        @abbr = abbr
        @side = side
        @string = (side.equal?(:first) ? abbr.to_s : abbr.to_s.downcase).freeze
        @hash = [abbr, side].hash
        @inspect = "#<#{self.class} #{@string}>".freeze

        freeze
      end

      # ========================================================================
      # String Conversion
      # ========================================================================

      # Returns the SIN string representation.
      #
      # Returns a pre-computed, frozen string — zero allocation per call.
      #
      # @return [String] The single-character SIN string
      #
      # @example
      #   Sashite::Sin.parse("C").to_s   # => "C"
      #   Sashite::Sin.parse("c").to_s   # => "c"
      def to_s
        @string
      end

      # ========================================================================
      # Side Queries
      # ========================================================================

      # Checks if the Identifier belongs to the first player.
      #
      # @return [Boolean] true if first player
      #
      # @example
      #   Sashite::Sin.parse("C").first_player?  # => true
      def first_player?
        side.equal?(:first)
      end

      # Checks if the Identifier belongs to the second player.
      #
      # @return [Boolean] true if second player
      #
      # @example
      #   Sashite::Sin.parse("c").second_player?  # => true
      def second_player?
        side.equal?(:second)
      end

      # ========================================================================
      # Comparison Queries
      # ========================================================================

      # Checks if two Identifiers have the same abbreviation.
      #
      # @param other [Identifier] The other Identifier to compare
      # @return [Boolean] true if same abbreviation
      #
      # @example
      #   sin1 = Sashite::Sin.parse("C")
      #   sin2 = Sashite::Sin.parse("c")
      #   sin1.same_abbr?(sin2)  # => true
      def same_abbr?(other)
        abbr.equal?(other.abbr)
      end

      # Checks if two Identifiers have the same side.
      #
      # @param other [Identifier] The other Identifier to compare
      # @return [Boolean] true if same side
      #
      # @example
      #   sin1 = Sashite::Sin.parse("C")
      #   sin2 = Sashite::Sin.parse("S")
      #   sin1.same_side?(sin2)  # => true
      def same_side?(other)
        side.equal?(other.side)
      end

      # ========================================================================
      # Equality
      # ========================================================================

      # Checks equality with another Identifier.
      #
      # With the flyweight pool, equal identifiers are always the same object
      # (i.e., == implies equal?). Value-based comparison is provided for
      # correctness when comparing across different object sources.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] true if equal
      #
      # @example
      #   Sashite::Sin.parse("C") == Sashite::Sin.fetch(:C, :first)  # => true
      def ==(other)
        equal?(other) || (self.class === other && abbr.equal?(other.abbr) && side.equal?(other.side))
      end

      alias eql? ==

      # Returns a pre-computed hash code for the Identifier.
      #
      # @return [Integer] Hash code
      def hash
        @hash
      end

      # Returns a pre-computed inspect string for the Identifier.
      #
      # @return [String] Inspect representation
      #
      # @example
      #   Sashite::Sin.parse("C").inspect  # => "#<Sashite::Sin::Identifier C>"
      def inspect
        @inspect
      end

      private

      # ========================================================================
      # Private Validation
      # ========================================================================

      def validate_abbr!(abbr)
        return if ::Symbol === abbr && Constants::VALID_ABBRS.include?(abbr)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_ABBR
      end

      def validate_side!(side)
        return if ::Symbol === side && Constants::VALID_SIDES.include?(side)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_SIDE
      end

      # ========================================================================
      # Flyweight Instance Pool
      # ========================================================================

      public

      # Component-keyed pool: [abbr, side] → Identifier.
      #
      # Used by {Sashite::Sin.fetch} for direct lookup by structured components.
      #
      # @return [Hash{Array(Symbol, Symbol) => Identifier}]
      POOL = {}.tap { |pool|
        Constants::VALID_ABBRS.each do |abbr|
          Constants::VALID_SIDES.each do |side|
            pool[[abbr, side]] = new(abbr, side)
          end
        end
      }.freeze

      # Byte-keyed pool: ASCII byte → Identifier.
      #
      # Used by the parser for O(1) lookup from a validated byte.
      # Returns nil for non-letter bytes, doubling as implicit validation.
      #
      # @return [Hash{Integer => Identifier}]
      BYTE_POOL = {}.tap { |pool|
        (0x41..0x5A).each { |b| pool[b] = POOL[[b.chr.to_sym, :first]] }
        (0x61..0x7A).each { |b| pool[b] = POOL[[(b - 32).chr.to_sym, :second]] }
      }.freeze

      private_class_method :new
    end
  end
end
