# frozen_string_literal: true

require_relative "constants"
require_relative "errors"

module Sashite
  module Sin
    # Represents a parsed SIN (Style Identifier Notation) identifier.
    #
    # An Identifier encodes two attributes:
    # - Style: the piece style (A-Z as uppercase symbol)
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
      # Valid style symbols (A-Z).
      VALID_STYLES = Constants::VALID_STYLES

      # Valid side symbols.
      VALID_SIDES = Constants::VALID_SIDES

      # @return [Symbol] Piece style (:A to :Z, always uppercase)
      attr_reader :style

      # @return [Symbol] Player side (:first or :second)
      attr_reader :side

      # Creates a new Identifier instance.
      #
      # @param style [Symbol] Piece style (:A to :Z)
      # @param side [Symbol] Player side (:first or :second)
      # @return [Identifier] A new frozen Identifier instance
      # @raise [Errors::Argument] If any attribute is invalid
      #
      # @example
      #   Identifier.new(:C, :first)
      #   Identifier.new(:S, :second)
      def initialize(style, side)
        validate_style!(style)
        validate_side!(side)

        @style = style
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
        letter
      end

      # Returns the letter component of the SIN.
      #
      # @return [String] Uppercase for first player, lowercase for second
      #
      # @example
      #   Identifier.new(:C, :first).letter   # => "C"
      #   Identifier.new(:C, :second).letter  # => "c"
      def letter
        base = String(style)

        case side
        when :first  then base.upcase
        when :second then base.downcase
        end
      end

      # ========================================================================
      # Side Transformations
      # ========================================================================

      # Returns a new Identifier with the opposite side.
      #
      # @return [Identifier] A new Identifier with flipped side
      #
      # @example
      #   sin = Identifier.new(:C, :first)
      #   sin.flip.to_s  # => "c"
      def flip
        new_side = first_player? ? :second : :first
        self.class.new(style, new_side)
      end

      # ========================================================================
      # Attribute Transformations
      # ========================================================================

      # Returns a new Identifier with a different style.
      #
      # @param new_style [Symbol] The new piece style (:A to :Z)
      # @return [Identifier] A new Identifier with the specified style
      # @raise [Errors::Argument] If the style is invalid
      #
      # @example
      #   sin = Identifier.new(:C, :first)
      #   sin.with_style(:S).to_s  # => "S"
      def with_style(new_style)
        return self if style.equal?(new_style)

        self.class.new(new_style, side)
      end

      # Returns a new Identifier with a different side.
      #
      # @param new_side [Symbol] The new side (:first or :second)
      # @return [Identifier] A new Identifier with the specified side
      # @raise [Errors::Argument] If the side is invalid
      #
      # @example
      #   sin = Identifier.new(:C, :first)
      #   sin.with_side(:second).to_s  # => "c"
      def with_side(new_side)
        return self if side.equal?(new_side)

        self.class.new(style, new_side)
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

      # Checks if two Identifiers have the same style.
      #
      # @param other [Identifier] The other Identifier to compare
      # @return [Boolean] true if same style
      #
      # @example
      #   sin1 = Identifier.new(:C, :first)
      #   sin2 = Identifier.new(:C, :second)
      #   sin1.same_style?(sin2)  # => true
      def same_style?(other)
        style.equal?(other.style)
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

        style.equal?(other.style) && side.equal?(other.side)
      end

      alias eql? ==

      # Returns a hash code for the Identifier.
      #
      # @return [Integer] Hash code
      def hash
        [style, side].hash
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

      def validate_style!(style)
        return if ::Symbol === style && Constants::VALID_STYLES.include?(style)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_STYLE
      end

      def validate_side!(side)
        return if ::Symbol === side && Constants::VALID_SIDES.include?(side)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_SIDE
      end
    end
  end
end
