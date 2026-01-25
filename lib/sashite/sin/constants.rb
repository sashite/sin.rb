# frozen_string_literal: true

module Sashite
  module Sin
    # Constants for the SIN (Style Identifier Notation) specification.
    #
    # Defines valid values for abbreviations and sides, as well as formatting constants.
    #
    # @example Accessing valid abbreviations
    #   Constants::VALID_ABBRS  # => [:A, :B, ..., :Z]
    #
    # @example Accessing valid sides
    #   Constants::VALID_SIDES  # => [:first, :second]
    #
    # @see https://sashite.dev/specs/sin/1.0.0/
    module Constants
      # Valid abbreviation symbols (A-Z as uppercase symbols).
      #
      # @return [Array<Symbol>] Array of 26 valid abbreviation symbols
      VALID_ABBRS = %i[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z].freeze

      # Valid side symbols.
      #
      # @return [Array<Symbol>] Array of valid side symbols
      VALID_SIDES = %i[first second].freeze

      # Maximum length of a valid SIN string.
      #
      # @return [Integer] Maximum string length (1)
      MAX_STRING_LENGTH = 1

      # Empty string constant for internal use.
      #
      # @return [String] Empty string
      EMPTY_STRING = ""
    end
  end
end
