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
    # Instances are immutable (frozen after creation).
    #
    # @example Creating identifiers
    #   sin = Identifier.new(:C, :first)
    #   sin = Identifier.new(:S, :second)
    #
    # @example String conversion
    #   Identifier.new(:C, :first).to_s   # => "C"
    #   Identifier.new(:C, :second).to_s  # => "c"
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
      # @example
      #   Identifier.new(:C, :first)
      #   Identifier.new(:S, :second)
      def initialize(abbr, side)
        validate_abbr!(abbr)
        validate_side!(side)

        @abbr = abbr
        @side = side

        freeze
      end

      # ========================================================================
      # String Conversion
      # ========================================================================

      # Returns the SIN string representation.
      #
      # @return [String] The single-character SIN string
      #
      # @example
      #   Identifier.new(:C, :first).to_s   # => "C"
      #   Identifier.new(:C, :second).to_s  # => "c"
      def to_s
        base = String(abbr)

        case side
        when :first  then base.upcase
        when :second then base.downcase
        end
      end

      # ========================================================================
      # Side Queries
      # ========================================================================

      # Checks if the Identifier belongs to the first player.
      #
      # @return [Boolean] true if first player
      #
      # @example
      #   Identifier.new(:C, :first).first_player?  # => true
      def first_player?
        side.equal?(:first)
      end

      # Checks if the Identifier belongs to the second player.
      #
      # @return [Boolean] true if second player
      #
      # @example
      #   Identifier.new(:C, :second).second_player?  # => true
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
      #   sin1 = Identifier.new(:C, :first)
      #   sin2 = Identifier.new(:C, :second)
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
      #   sin1 = Identifier.new(:C, :first)
      #   sin2 = Identifier.new(:S, :first)
      #   sin1.same_side?(sin2)  # => true
      def same_side?(other)
        side.equal?(other.side)
      end

      # ========================================================================
      # Equality
      # ========================================================================

      # Checks equality with another Identifier.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] true if equal
      #
      # @example
      #   sin1 = Identifier.new(:C, :first)
      #   sin2 = Identifier.new(:C, :first)
      #   sin1 == sin2  # => true
      def ==(other)
        return false unless self.class === other

        abbr.equal?(other.abbr) && side.equal?(other.side)
      end

      alias eql? ==

      # Returns a hash code for the Identifier.
      #
      # @return [Integer] Hash code
      def hash
        [abbr, side].hash
      end

      # Returns an inspect string for the Identifier.
      #
      # @return [String] Inspect representation
      #
      # @example
      #   Identifier.new(:C, :first).inspect  # => "#<Sashite::Sin::Identifier C>"
      def inspect
        "#<#{self.class} #{self}>"
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
    end
  end
end
