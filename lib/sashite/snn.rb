# frozen_string_literal: true

require_relative "snn/style"

module Sashite
  # SNN (Style Name Notation) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying styles in abstract strategy board games.
  # SNN uses single ASCII letters with case-based side encoding, enabling clear
  # distinction between different style families in multi-style gaming environments.
  #
  # Format: <style-letter>
  # - Uppercase letter: First player styles (A, B, C, ..., Z)
  # - Lowercase letter: Second player styles (a, b, c, ..., z)
  # - Single character only: Each SNN identifier is exactly one ASCII letter
  #
  # Examples:
  #   "C"  - First player, C style family
  #   "c"  - Second player, C style family
  #   "S"  - First player, S style family
  #   "s"  - Second player, S style family
  #
  # See: https://sashite.dev/specs/snn/1.0.0/
  module Snn
    # Check if a string is a valid SNN notation
    #
    # @param snn_string [String] the string to validate
    # @return [Boolean] true if valid SNN, false otherwise
    #
    # @example Validate various SNN formats
    #   Sashite::Snn.valid?("C") # => true
    #   Sashite::Snn.valid?("c") # => true
    #   Sashite::Snn.valid?("CHESS") # => false (multi-character)
    #   Sashite::Snn.valid?("1") # => false (not a letter)
    def self.valid?(snn_string)
      Style.valid?(snn_string)
    end

    # Parse an SNN string into a Style object
    #
    # @param snn_string [String] SNN notation string
    # @return [Snn::Style] parsed style object with letter and side attributes
    # @raise [ArgumentError] if the SNN string is invalid
    # @example Parse different SNN formats
    #   Sashite::Snn.parse("C") # => #<Snn::Style letter=:C side=:first>
    #   Sashite::Snn.parse("c") # => #<Snn::Style letter=:c side=:second>
    #   Sashite::Snn.parse("S") # => #<Snn::Style letter=:S side=:first>
    def self.parse(snn_string)
      Style.parse(snn_string)
    end

    # Create a new style instance
    #
    # @param letter [Symbol] style letter (single ASCII letter as symbol)
    # @param side [Symbol] player side (:first or :second)
    # @return [Snn::Style] new immutable style instance
    # @raise [ArgumentError] if parameters are invalid
    # @example Create styles directly
    #   Sashite::Snn.style(:C, :first)  # => #<Snn::Style letter=:C side=:first>
    #   Sashite::Snn.style(:s, :second) # => #<Snn::Style letter=:s side=:second>
    def self.style(letter, side)
      Style.new(letter, side)
    end
  end
end
