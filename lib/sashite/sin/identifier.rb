# frozen_string_literal: true

module Sashite
  module Sin
    # Represents an identifier in SIN (Style Identifier Notation) format.
    #
    # ## Concept
    #
    # SIN addresses the fundamental need to identify which style system governs piece behavior
    # while simultaneously indicating which player controls pieces of that style. In cross-style
    # scenarios where different players use different game traditions, this dual encoding becomes
    # essential for unambiguous piece identification.
    #
    # ## Dual-Purpose Encoding
    #
    # Each SIN identifier serves two functions:
    # - **Style Family Identification**: The family choice indicates which rule system applies
    # - **Player Assignment**: The side indicates which player uses this style as their native system
    #
    # ## Format Structure
    #
    # An identifier consists of a single ASCII letter with case-based side encoding:
    # - Uppercase letter: first player (A, B, C, ..., Z)
    # - Lowercase letter: second player (a, b, c, ..., z)
    #
    # The letter representation combines two distinct semantic components:
    # - **Style Family**: The underlying ASCII character (A-Z), representing the game tradition or rule system
    # - **Player Assignment**: The case of the character (uppercase/lowercase), representing which player uses this style
    #
    # Examples of letter composition:
    # - Family :C + Side :first  → Letter "C" (Chess, First player)
    # - Family :C + Side :second → Letter "c" (Chess, Second player)
    # - Family :S + Side :first  → Letter "S" (Shōgi, First player)
    # - Family :S + Side :second → Letter "s" (Shōgi, Second player)
    #
    # ## Canonical Representation
    #
    # SIN enforces canonical representation where each style-player combination has exactly one
    # valid identifier within a given context. This ensures consistent interpretation across
    # different implementations while allowing flexibility for collision resolution.
    #
    # ## Immutability
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the SIN Specification v1.0.0 functional design principles.
    #
    # @example Basic usage with traditional game styles
    #   # Chess family identifiers
    #   chess_white = Sashite::Sin::Identifier.parse("C")  # Family :C, Side :first
    #   chess_black = Sashite::Sin::Identifier.parse("c")  # Family :C, Side :second
    #
    #   # Shōgi family identifiers
    #   shogi_sente = Sashite::Sin::Identifier.parse("S")  # Family :S, Side :first
    #   shogi_gote  = Sashite::Sin::Identifier.parse("s")  # Family :S, Side :second
    #
    # @example Dual-purpose encoding demonstration
    #   identifier = Sashite::Sin::Identifier.parse("C")
    #   identifier.family  # => :C (Style Family)
    #   identifier.side    # => :first (Player Assignment)
    #   identifier.letter  # => "C" (Combined representation)
    #
    # @example Cross-style scenarios
    #   # Different families in one match (requires compatible board structures)
    #   chess_style = Sashite::Sin::Identifier.parse("C")  # First player uses Chess family
    #   ogi_style   = Sashite::Sin::Identifier.parse("o")  # Second player uses Ōgi family
    #
    # @see https://sashite.dev/specs/sin/1.0.0/ SIN Specification v1.0.0
    class Identifier
      # SIN validation pattern matching the specification regular expression
      # Grammar: <sin> ::= <uppercase-letter> | <lowercase-letter>
      SIN_PATTERN = /\A[A-Za-z]\z/

      # Player side constants following SIN v1.0.0 two-player constraint
      FIRST_PLAYER = :first
      SECOND_PLAYER = :second

      # Valid families (A-Z)
      VALID_FAMILIES = (:A..:Z).to_a.freeze

      # Valid sides array for validation
      VALID_SIDES = [FIRST_PLAYER, SECOND_PLAYER].freeze

      # Error messages with SIN-compliant terminology
      ERROR_INVALID_SIN = "Invalid SIN string: %s. Must be a single ASCII letter (A-Z, a-z)"
      ERROR_INVALID_FAMILY = "Family must be a symbol from :A to :Z representing Style Family, got: %s"
      ERROR_INVALID_SIDE = "Side must be :first or :second following SIN two-player constraint, got: %s"

      # @return [Symbol] the style family (:A to :Z)
      #   This represents the Style Family component - the game tradition or rule system
      attr_reader :family

      # @return [Symbol] the player side (:first or :second)
      #   This represents the Player Assignment component
      attr_reader :side

      # Create a new identifier instance with canonical representation
      #
      # @param family [Symbol] style family (:A to :Z representing Style Family)
      # @param side [Symbol] player side (:first or :second representing Player Assignment)
      # @raise [ArgumentError] if parameters are invalid
      #
      # @example Create identifiers with family and side separation
      #   # Chess family identifiers
      #   chess_first  = Sashite::Sin::Identifier.new(:C, :first)   # => Family=:C, Side=:first
      #   chess_second = Sashite::Sin::Identifier.new(:C, :second)  # => Family=:C, Side=:second
      #
      # @example Style Family and Player Assignment demonstration
      #   identifier = Sashite::Sin::Identifier.new(:S, :first)
      #   identifier.family  # => :S (Shōgi Style Family)
      #   identifier.side    # => :first (First Player Assignment)
      #   identifier.letter  # => "S" (Combined representation)
      def initialize(family, side)
        self.class.validate_family(family)
        self.class.validate_side(side)

        @family = family
        @side = side

        freeze
      end

      # Parse an SIN string into an Identifier object with dual-purpose encoding
      #
      # The family and side are inferred from both the character choice (Style Family)
      # and case (Player Assignment):
      # - Uppercase letter → Style Family + First player
      # - Lowercase letter → Style Family + Second player
      #
      # @param sin_string [String] SIN notation string (single ASCII letter)
      # @return [Identifier] parsed identifier object with Family and Side attributes
      # @raise [ArgumentError] if the SIN string is invalid
      #
      # @example Parse SIN strings with case-based Player Assignment inference
      #   Sashite::Sin::Identifier.parse("C")  # => Family=:C, Side=:first (Chess, White)
      #   Sashite::Sin::Identifier.parse("c")  # => Family=:C, Side=:second (Chess, Black)
      #   Sashite::Sin::Identifier.parse("S")  # => Family=:S, Side=:first (Shōgi, Sente)
      #   Sashite::Sin::Identifier.parse("s")  # => Family=:S, Side=:second (Shōgi, Gote)
      #
      # @example Traditional game styles from SIN Examples
      #   # Chess (8×8 board)
      #   chess_white = Sashite::Sin::Identifier.parse("C")  # First player (White pieces)
      #   chess_black = Sashite::Sin::Identifier.parse("c")  # Second player (Black pieces)
      #
      #   # Xiangqi (9×10 board)
      #   xiangqi_red   = Sashite::Sin::Identifier.parse("X")  # First player (Red pieces)
      #   xiangqi_black = Sashite::Sin::Identifier.parse("x")  # Second player (Black pieces)
      def self.parse(sin_string)
        string_value = String(sin_string)
        validate_sin_string(string_value)

        # Extract Style Family (case-insensitive) and Player Assignment (case-sensitive)
        family_symbol = string_value.upcase.to_sym
        identifier_side = string_value == string_value.upcase ? FIRST_PLAYER : SECOND_PLAYER

        new(family_symbol, identifier_side)
      end

      # Check if a string is a valid SIN notation according to specification
      #
      # Validates against the SIN grammar:
      # <sin> ::= <uppercase-letter> | <lowercase-letter>
      #
      # @param sin_string [String] the string to validate
      # @return [Boolean] true if valid SIN, false otherwise
      #
      # @example Validate SIN strings against specification
      #   Sashite::Sin::Identifier.valid?("C")      # => true (Chess first player)
      #   Sashite::Sin::Identifier.valid?("c")      # => true (Chess second player)
      #   Sashite::Sin::Identifier.valid?("CHESS")  # => false (multi-character)
      #   Sashite::Sin::Identifier.valid?("1")      # => false (not ASCII letter)
      def self.valid?(sin_string)
        return false unless sin_string.is_a?(::String)

        sin_string.match?(SIN_PATTERN)
      end

      # Convert the identifier to its SIN string representation
      #
      # Returns the canonical SIN notation with proper case encoding for Player Assignment.
      #
      # @return [String] SIN notation string (single ASCII letter)
      #
      # @example Display identifiers in canonical SIN format
      #   chess_first.to_s   # => "C" (Chess family, first player)
      #   chess_second.to_s  # => "c" (Chess family, second player)
      #   shogi_first.to_s   # => "S" (Shōgi family, first player)
      def to_s
        letter
      end

      # Get the letter representation combining Style Family and Player Assignment
      #
      # @return [String] letter representation with proper case encoding
      #
      # @example Letter representation with dual-purpose encoding
      #   chess_first.letter   # => "C" (Chess family, first player)
      #   chess_second.letter  # => "c" (Chess family, second player)
      #   shogi_first.letter   # => "S" (Shōgi family, first player)
      def letter
        first_player? ? family.to_s.upcase : family.to_s.downcase
      end

      # Create a new identifier with opposite Player Assignment (flip sides)
      #
      # Transforms Player Assignment while maintaining Style Family:
      # - First player → Second player (uppercase → lowercase)
      # - Second player → First player (lowercase → uppercase)
      #
      # @return [Identifier] new immutable identifier instance with flipped Player Assignment
      #
      # @example Flip Player Assignment within same Style Family
      #   chess_white = Sashite::Sin::Identifier.parse("C")
      #   chess_black = chess_white.flip  # => Family=:C, Side=:second
      #
      #   shogi_sente = Sashite::Sin::Identifier.parse("S")
      #   shogi_gote  = shogi_sente.flip  # => Family=:S, Side=:second
      def flip
        self.class.new(family, opposite_side)
      end

      # Create a new identifier with a different Style Family (keeping same Player Assignment)
      #
      # Changes the Style Family component while preserving Player Assignment.
      #
      # @param new_family [Symbol] new Style Family (:A to :Z)
      # @return [Identifier] new immutable identifier instance with different Style Family
      #
      # @example Change Style Family while preserving Player Assignment
      #   chess_white = Sashite::Sin::Identifier.parse("C")     # Chess, first player
      #   shogi_white = chess_white.with_family(:S)             # Shōgi, first player
      #
      #   chess_black = Sashite::Sin::Identifier.parse("c")     # Chess, second player
      #   xiangqi_black = chess_black.with_family(:X)           # Xiangqi, second player
      def with_family(new_family)
        self.class.validate_family(new_family)
        return self if family == new_family

        self.class.new(new_family, side)
      end

      # Create a new identifier with a different Player Assignment (keeping same Style Family)
      #
      # Changes the Player Assignment component while preserving Style Family.
      #
      # @param new_side [Symbol] :first or :second
      # @return [Identifier] new immutable identifier instance with different Player Assignment
      #
      # @example Change Player Assignment within same Style Family
      #   chess_white = Sashite::Sin::Identifier.parse("C")     # Chess, first player
      #   chess_black = chess_white.with_side(:second)          # Chess, second player
      #
      #   shogi_sente = Sashite::Sin::Identifier.parse("S")     # Shōgi, first player
      #   shogi_gote  = shogi_sente.with_side(:second)          # Shōgi, second player
      def with_side(new_side)
        self.class.validate_side(new_side)
        return self if side == new_side

        self.class.new(family, new_side)
      end

      # Check if the identifier belongs to the first player
      #
      # @return [Boolean] true if first player (uppercase letter)
      #
      # @example Player identification
      #   Sashite::Sin::Identifier.parse("C").first_player?   # => true
      #   Sashite::Sin::Identifier.parse("c").first_player?   # => false
      def first_player?
        side == FIRST_PLAYER
      end

      # Check if the identifier belongs to the second player
      #
      # @return [Boolean] true if second player (lowercase letter)
      #
      # @example Player identification
      #   Sashite::Sin::Identifier.parse("c").second_player?  # => true
      #   Sashite::Sin::Identifier.parse("C").second_player?  # => false
      def second_player?
        side == SECOND_PLAYER
      end

      # Check if this identifier has the same Style Family as another
      #
      # Compares the Style Family component, ignoring Player Assignment.
      # This is useful for identifying pieces from the same game tradition in cross-style scenarios.
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if both identifiers use the same Style Family
      #
      # @example Compare Style Families across different Player Assignments
      #   chess_white = Sashite::Sin::Identifier.parse("C")  # Chess, first player
      #   chess_black = Sashite::Sin::Identifier.parse("c")  # Chess, second player
      #   shogi_white = Sashite::Sin::Identifier.parse("S")  # Shōgi, first player
      #
      #   chess_white.same_family?(chess_black)  # => true (both Chess family)
      #   chess_white.same_family?(shogi_white)  # => false (different families)
      def same_family?(other)
        return false unless other.is_a?(self.class)

        family == other.family
      end

      # Check if this identifier belongs to the same Player Assignment as another
      #
      # Compares the Player Assignment component of identifiers across different Style Families.
      # This is useful for grouping pieces by controlling player in multi-style games.
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if both identifiers belong to the same Player Assignment
      #
      # @example Compare Player Assignments across different Style Families
      #   chess_white = Sashite::Sin::Identifier.parse("C")  # Chess, first player
      #   shogi_white = Sashite::Sin::Identifier.parse("S")  # Shōgi, first player
      #   chess_black = Sashite::Sin::Identifier.parse("c")  # Chess, second player
      #
      #   chess_white.same_side?(shogi_white)  # => true (both first player)
      #   chess_white.same_side?(chess_black)  # => false (different players)
      def same_side?(other)
        return false unless other.is_a?(self.class)

        side == other.side
      end

      # Compatibility alias for same_family? to maintain API consistency
      #
      # @deprecated Use {#same_family?} instead for clearer semantics
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if both identifiers use the same Style Family
      def same_letter?(other)
        same_family?(other)
      end

      # Custom equality comparison
      #
      # Two identifiers are equal if they have identical Family and Side attributes.
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if both objects are identifiers with identical Family and Side
      #
      # @example Equality comparison
      #   id1 = Sashite::Sin::Identifier.parse("C")
      #   id2 = Sashite::Sin::Identifier.parse("C")
      #   id3 = Sashite::Sin::Identifier.parse("c")
      #
      #   id1 == id2  # => true (identical Family and Side)
      #   id1 == id3  # => false (different Player Assignment)
      def ==(other)
        return false unless other.is_a?(self.class)

        family == other.family && side == other.side
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value based on class, Family, and Side
      def hash
        [self.class, family, side].hash
      end

      # Validate that the family is a valid Style Family symbol
      #
      # @param family [Symbol] the family to validate
      # @raise [ArgumentError] if invalid
      def self.validate_family(family)
        return if VALID_FAMILIES.include?(family)

        raise ::ArgumentError, format(ERROR_INVALID_FAMILY, family.inspect)
      end

      # Validate that the side follows SIN two-player constraint
      #
      # @param side [Symbol] the side to validate
      # @raise [ArgumentError] if invalid
      def self.validate_side(side)
        return if VALID_SIDES.include?(side)

        raise ::ArgumentError, format(ERROR_INVALID_SIDE, side.inspect)
      end

      # Validate SIN string format against specification grammar
      #
      # @param string [String] string to validate
      # @raise [ArgumentError] if string doesn't match SIN pattern
      def self.validate_sin_string(string)
        return if string.match?(SIN_PATTERN)

        raise ::ArgumentError, format(ERROR_INVALID_SIN, string)
      end

      private_class_method :validate_sin_string

      private

      # Get the opposite Player Assignment
      #
      # @return [Symbol] the opposite side
      def opposite_side
        first_player? ? SECOND_PLAYER : FIRST_PLAYER
      end
    end
  end
end
