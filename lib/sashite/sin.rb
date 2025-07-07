# frozen_string_literal: true

require_relative "sin/style"

module Sashite
  # SIN (Style Identifier Notation) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying styles in abstract strategy board games.
  # SIN uses single ASCII letters with case-based side encoding, enabling clear
  # distinction between different style families in multi-style gaming environments.
  #
  # Format: <style-letter>
  # - Uppercase letter: First player styles (A, B, C, ..., Z)
  # - Lowercase letter: Second player styles (a, b, c, ..., z)
  # - Single character only: Each SIN identifier is exactly one ASCII letter
  #
  # Examples:
  #   "C"  - First player, C style family
  #   "c"  - Second player, C style family
  #   "S"  - First player, S style family
  #   "s"  - Second player, S style family
  #
  # See: https://sashite.dev/specs/sin/1.0.0/
  module Sin
    # Check if a string is a valid SIN notation
    #
    # @param sin_string [String] the string to validate
    # @return [Boolean] true if valid SIN, false otherwise
    #
    # @example Validate various SIN formats
    #   Sashite::Sin.valid?("C") # => true
    #   Sashite::Sin.valid?("c") # => true
    #   Sashite::Sin.valid?("CHESS") # => false (multi-character)
    #   Sashite::Sin.valid?("1") # => false (not a letter)
    def self.valid?(sin_string)
      Style.valid?(sin_string)
    end

    # Parse an SIN string into a Style object
    #
    # @param sin_string [String] SIN notation string
    # @return [Sin::Style] parsed style object with letter and side attributes
    # @raise [ArgumentError] if the SIN string is invalid
    # @example Parse different SIN formats
    #   Sashite::Sin.parse("C") # => #<Sin::Style letter=:C side=:first>
    #   Sashite::Sin.parse("c") # => #<Sin::Style letter=:c side=:second>
    #   Sashite::Sin.parse("S") # => #<Sin::Style letter=:S side=:first>
    def self.parse(sin_string)
      Style.parse(sin_string)
    end

    # Create a new style instance
    #
    # @param letter [Symbol] style letter (single ASCII letter as symbol)
    # @param side [Symbol] player side (:first or :second)
    # @return [Sin::Style] new immutable style instance
    # @raise [ArgumentError] if parameters are invalid
    # @example Create styles directly
    #   Sashite::Sin.style(:C, :first)  # => #<Sin::Style letter=:C side=:first>
    #   Sashite::Sin.style(:s, :second) # => #<Sin::Style letter=:s side=:second>
    def self.style(letter, side)
      Style.new(letter, side)
    end
  end
end
