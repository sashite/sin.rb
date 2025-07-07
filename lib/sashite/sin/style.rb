# frozen_string_literal: true

module Sashite
  module Sin
    # Represents a style in SIN (Style Identifier Notation) format.
    #
    # A style consists of a single ASCII letter with case-based side encoding:
    # - Uppercase letter: first player (A, B, C, ..., Z)
    # - Lowercase letter: second player (a, b, c, ..., z)
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the SIN Specification v1.0.0 with Letter and Side attributes.
    class Style
      # SIN validation pattern matching the specification
      SIN_PATTERN = /\A[A-Za-z]\z/

      # Player side constants
      FIRST_PLAYER = :first
      SECOND_PLAYER = :second

      # Valid sides
      VALID_SIDES = [FIRST_PLAYER, SECOND_PLAYER].freeze

      # Error messages
      ERROR_INVALID_SIN = "Invalid SIN string: %s"
      ERROR_INVALID_LETTER = "Letter must be a single ASCII letter symbol (A-Z, a-z), got: %s"
      ERROR_INVALID_SIDE = "Side must be :first or :second, got: %s"

      # @return [Symbol] the style letter (single ASCII letter as symbol)
      attr_reader :letter

      # @return [Symbol] the player side (:first or :second)
      attr_reader :side

      # Create a new style instance
      #
      # @param letter [Symbol] style letter (single ASCII letter as symbol)
      # @param side [Symbol] player side (:first or :second)
      # @raise [ArgumentError] if parameters are invalid
      def initialize(letter, side)
        self.class.validate_letter(letter)
        self.class.validate_side(side)

        @letter = letter
        @side = side

        freeze
      end

      # Parse an SIN string into a Style object
      #
      # @param sin_string [String] SIN notation string (single ASCII letter)
      # @return [Style] parsed style object with letter and inferred side
      # @raise [ArgumentError] if the SIN string is invalid
      # @example Parse SIN strings with case-based side inference
      #   Sashite::Sin::Style.parse("C") # => #<Sin::Style letter=:C side=:first>
      #   Sashite::Sin::Style.parse("c") # => #<Sin::Style letter=:c side=:second>
      #   Sashite::Sin::Style.parse("S") # => #<Sin::Style letter=:S side=:first>
      def self.parse(sin_string)
        string_value = String(sin_string)
        validate_sin_string(string_value)

        # Determine side from case
        style_side = string_value == string_value.upcase ? FIRST_PLAYER : SECOND_PLAYER

        # Use the letter directly as symbol
        style_letter = string_value.to_sym

        new(style_letter, style_side)
      end

      # Check if a string is a valid SIN notation
      #
      # @param sin_string [String] the string to validate
      # @return [Boolean] true if valid SIN, false otherwise
      #
      # @example Validate SIN strings
      #   Sashite::Sin::Style.valid?("C") # => true
      #   Sashite::Sin::Style.valid?("c") # => true
      #   Sashite::Sin::Style.valid?("CHESS") # => false (multi-character)
      def self.valid?(sin_string)
        return false unless sin_string.is_a?(::String)

        sin_string.match?(SIN_PATTERN)
      end

      # Convert the style to its SIN string representation
      #
      # @return [String] SIN notation string (single ASCII letter)
      # @example Display styles
      #   style.to_s  # => "C" (first player, C family)
      #   style.to_s  # => "c" (second player, C family)
      #   style.to_s  # => "S" (first player, S family)
      def to_s
        letter.to_s
      end

      # Create a new style with opposite ownership (side)
      #
      # @return [Style] new immutable style instance with flipped side
      # @example Flip player sides
      #   style.flip  # (:C, :first) => (:c, :second)
      def flip
        new_letter = first_player? ? letter.to_s.downcase.to_sym : letter.to_s.upcase.to_sym
        self.class.new(new_letter, opposite_side)
      end

      # Create a new style with a different letter (keeping same side)
      #
      # @param new_letter [Symbol] new letter (single ASCII letter as symbol)
      # @return [Style] new immutable style instance with different letter
      # @example Change style letter
      #   style.with_letter(:S)  # (:C, :first) => (:S, :first)
      def with_letter(new_letter)
        self.class.validate_letter(new_letter)
        return self if letter == new_letter

        # Ensure the new letter has the correct case for the current side
        adjusted_letter = first_player? ? new_letter.to_s.upcase.to_sym : new_letter.to_s.downcase.to_sym
        self.class.new(adjusted_letter, side)
      end

      # Create a new style with a different side (keeping same letter family)
      #
      # @param new_side [Symbol] :first or :second
      # @return [Style] new immutable style instance with different side
      # @example Change player side
      #   style.with_side(:second)  # (:C, :first) => (:c, :second)
      def with_side(new_side)
        self.class.validate_side(new_side)
        return self if side == new_side

        # Adjust letter case for the new side
        new_letter = new_side == FIRST_PLAYER ? letter.to_s.upcase.to_sym : letter.to_s.downcase.to_sym
        self.class.new(new_letter, new_side)
      end

      # Check if the style belongs to the first player
      #
      # @return [Boolean] true if first player
      def first_player?
        side == FIRST_PLAYER
      end

      # Check if the style belongs to the second player
      #
      # @return [Boolean] true if second player
      def second_player?
        side == SECOND_PLAYER
      end

      # Check if this style has the same letter family as another
      #
      # @param other [Style] style to compare with
      # @return [Boolean] true if both styles use the same letter family (case-insensitive)
      # @example Compare style letter families
      #   c_style.same_letter?(C_style)  # (:c, :second) and (:C, :first) => true
      def same_letter?(other)
        return false unless other.is_a?(self.class)

        letter.to_s.upcase == other.letter.to_s.upcase
      end

      # Check if this style belongs to the same side as another
      #
      # @param other [Style] style to compare with
      # @return [Boolean] true if both styles belong to the same side
      def same_side?(other)
        return false unless other.is_a?(self.class)

        side == other.side
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if both objects are styles with identical letter and side
      def ==(other)
        return false unless other.is_a?(self.class)

        letter == other.letter && side == other.side
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value based on class, letter, and side
      def hash
        [self.class, letter, side].hash
      end

      # Validate that the letter is a valid single ASCII letter symbol
      #
      # @param letter [Symbol] the letter to validate
      # @raise [ArgumentError] if invalid
      def self.validate_letter(letter)
        return if valid_letter?(letter)

        raise ::ArgumentError, format(ERROR_INVALID_LETTER, letter.inspect)
      end

      # Validate that the side is a valid symbol
      #
      # @param side [Symbol] the side to validate
      # @raise [ArgumentError] if invalid
      def self.validate_side(side)
        return if VALID_SIDES.include?(side)

        raise ::ArgumentError, format(ERROR_INVALID_SIDE, side.inspect)
      end

      # Check if a letter is valid (single ASCII letter symbol)
      #
      # @param letter [Object] the letter to check
      # @return [Boolean] true if valid
      def self.valid_letter?(letter)
        return false unless letter.is_a?(::Symbol)

        letter_string = letter.to_s
        return false if letter_string.empty?

        # Must be exactly one ASCII letter
        letter_string.match?(SIN_PATTERN)
      end

      # Validate SIN string format
      #
      # @param string [String] string to validate
      # @raise [ArgumentError] if string doesn't match SIN pattern
      def self.validate_sin_string(string)
        return if string.match?(SIN_PATTERN)

        raise ::ArgumentError, format(ERROR_INVALID_SIN, string)
      end

      private_class_method :valid_letter?, :validate_sin_string

      private

      # Get the opposite side
      #
      # @return [Symbol] the opposite side
      def opposite_side
        first_player? ? SECOND_PLAYER : FIRST_PLAYER
      end
    end
  end
end
