# frozen_string_literal: true

require_relative "sin/identifier"

module Sashite
  # SIN (Style Identifier Notation) implementation for Ruby
  #
  # Provides a compact, ASCII-based format for identifying styles in abstract strategy board games.
  # SIN uses single-character identifiers with case encoding to represent both style identity
  # and player assignment simultaneously.
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
  # - **Style Family Identification**: The letter choice indicates which rule system applies
  # - **Player Assignment**: The letter case indicates which player uses this style as their native system
  #
  # ## Format Specification
  #
  # Structure: `<style-letter>`
  #
  # Grammar (BNF):
  #   <sin> ::= <uppercase-letter> | <lowercase-letter>
  #   <uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
  #   <lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
  #
  # Regular Expression: `/\A[A-Za-z]\z/`
  #
  # ## Style Attribute Mapping
  #
  # SIN encodes style attributes using the following correspondence:
  #
  # | Style Attribute | SIN Encoding | Examples |
  # |-----------------|--------------|----------|
  # | **Letter** | Single ASCII character | `C`, `c`, `S`, `s` |
  # | **Style Family** | ASCII letter choice (A-Z) | `C`/`c` = Chess, `S`/`s` = Shōgi |
  # | **Player Assignment** | Letter case | `C` = First player, `c` = Second player |
  #
  # The **Letter** attribute combines two distinct semantic components:
  # - **Style Family**: The underlying ASCII character (A-Z), representing the game tradition or rule system
  # - **Player Assignment**: The case of the character (uppercase/lowercase), representing which player uses this style
  #
  # ## Character Selection Conventions
  #
  # ### Primary Convention: First Letter
  # By convention, SIN identifiers should preferably use the **first letter** of the corresponding SNN style name:
  # - `Chess` → `C`/`c`
  # - `Shogi` → `S`/`s`
  # - `Xiangqi` → `X`/`x`
  # - `Makruk` → `M`/`m`
  # - `Janggi` → `J`/`j`
  #
  # ### Collision Resolution
  # When multiple styles would claim the same first letter, systematic collision resolution applies
  # using sequential letter selection from the SNN name until a unique identifier is found.
  #
  # ### Compatibility Groups
  # Styles requiring incompatible board structures can safely share SIN letters since they
  # cannot coexist in the same match.
  #
  # ## System Constraints
  #
  # - **26 possible identifiers** per player using ASCII letters
  # - **Exactly 2 players** through case distinction:
  #   - First player: Uppercase letters (`A-Z`)
  #   - Second player: Lowercase letters (`a-z`)
  # - **Single character** per style-player combination
  # - **Rule-agnostic** - independent of specific game mechanics
  #
  # ## Examples
  #
  # ### Traditional Game Styles
  #
  #   # Chess (8×8)
  #   chess_white = Sashite::Sin.parse("C")    # First player (White pieces)
  #   chess_black = Sashite::Sin.parse("c")    # Second player (Black pieces)
  #
  #   # Shōgi (9×9)
  #   shogi_sente = Sashite::Sin.parse("S")    # First player (Sente 先手)
  #   shogi_gote  = Sashite::Sin.parse("s")    # Second player (Gote 後手)
  #
  #   # Xiangqi (9×10)
  #   xiangqi_red   = Sashite::Sin.parse("X")  # First player (Red pieces)
  #   xiangqi_black = Sashite::Sin.parse("x")  # Second player (Black pieces)
  #
  # ### Cross-Style Scenarios
  #
  #   # Chess vs. Ōgi Match (both 8×8 compatible)
  #   chess_style = Sashite::Sin.parse("C")    # Chess style, first player
  #   ogi_style   = Sashite::Sin.parse("o")    # Ōgi style, second player
  #
  # ### All 26 Letters
  #
  #   # First player identifiers (A-Z)
  #   ("A".."Z").each { |letter| Sashite::Sin.parse(letter).first_player? }  # => all true
  #
  #   # Second player identifiers (a-z)
  #   ("a".."z").each { |letter| Sashite::Sin.parse(letter).second_player? } # => all true
  #
  # ## Design Properties
  #
  # - **ASCII compatibility**: Maximum portability across systems
  # - **Rule-agnostic**: Independent of specific game mechanics
  # - **Minimal overhead**: Single character per style-player combination
  # - **Flexible collision resolution**: Systematic approaches for identifier conflicts
  # - **Semantic clarity**: Distinct concepts for Letter (Style Family + Player Assignment)
  # - **SNN coordination**: Works harmoniously with formal style naming
  # - **Context-aware**: Adapts to avoid conflicts within specific game scenarios
  #
  # @see https://sashite.dev/specs/sin/1.0.0/ SIN Specification v1.0.0
  # @see https://sashite.dev/specs/sin/1.0.0/examples/ SIN Examples
  # @see https://sashite.dev/specs/snn/ Style Name Notation (SNN)
  module Sin
    # Check if a string is a valid SIN notation
    #
    # @param sin_string [String] the string to validate
    # @return [Boolean] true if valid SIN, false otherwise
    #
    # @example Validate various SIN formats
    #   Sashite::Sin.valid?("C")      # => true (Chess first player)
    #   Sashite::Sin.valid?("c")      # => true (Chess second player)
    #   Sashite::Sin.valid?("S")      # => true (Shōgi first player)
    #   Sashite::Sin.valid?("s")      # => true (Shōgi second player)
    #   Sashite::Sin.valid?("CHESS")  # => false (multi-character)
    #   Sashite::Sin.valid?("1")      # => false (not a letter)
    #   Sashite::Sin.valid?("")       # => false (empty string)
    def self.valid?(sin_string)
      Identifier.valid?(sin_string)
    end

    # Parse an SIN string into an Identifier object
    #
    # The identifier will have both letter and side attributes inferred from the case:
    # - Uppercase letter → first player (:first)
    # - Lowercase letter → second player (:second)
    #
    # @param sin_string [String] SIN notation string (single ASCII letter)
    # @return [Sin::Identifier] parsed identifier object with letter and side attributes
    # @raise [ArgumentError] if the SIN string is invalid
    #
    # @example Parse different SIN formats with dual-purpose encoding
    #   Sashite::Sin.parse("C")  # => #<Sashite::Sin::Identifier @family=:C, @side=:first>
    #   Sashite::Sin.parse("c")  # => #<Sashite::Sin::Identifier @family=:C, @side=:second>
    #   Sashite::Sin.parse("S")  # => #<Sashite::Sin::Identifier @family=:S, @side=:first>
    #   Sashite::Sin.parse("s")  # => #<Sashite::Sin::Identifier @family=:S, @side=:second>
    #
    # @example Traditional game styles
    #   chess_white = Sashite::Sin.parse("C")  # Chess, first player (White)
    #   chess_black = Sashite::Sin.parse("c")  # Chess, second player (Black)
    #   shogi_sente = Sashite::Sin.parse("S")  # Shōgi, first player (Sente)
    #   shogi_gote  = Sashite::Sin.parse("s")  # Shōgi, second player (Gote)
    def self.parse(sin_string)
      Identifier.parse(sin_string)
    end

    # Create a new identifier instance with canonical representation
    #
    # Ensures the letter case matches the specified side:
    # - :first side → uppercase letter
    # - :second side → lowercase letter
    #
    # @param family [Symbol] style family (:A to :Z representing Style Family)
    # @param side [Symbol] player side (:first or :second)
    # @return [Sin::Identifier] new immutable identifier instance
    # @raise [ArgumentError] if parameters are invalid
    #
    # @example Create identifiers with family and side separation
    #   Sashite::Sin.identifier(:C, :first)   # => #<Sashite::Sin::Identifier @family=:C, @side=:first>
    #   Sashite::Sin.identifier(:C, :second)  # => #<Sashite::Sin::Identifier @family=:C, @side=:second>
    #
    # @example Style family and player assignment
    #   chess_first  = Sashite::Sin.identifier(:C, :first)   # Chess family, first player
    #   chess_second = Sashite::Sin.identifier(:C, :second)  # Chess family, second player
    #
    #   chess_first.same_family?(chess_second)   # => true (same style family)
    #   chess_first.same_side?(chess_second)     # => false (different players)
    def self.identifier(family, side)
      Identifier.new(family, side)
    end
  end
end
