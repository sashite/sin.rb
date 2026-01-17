# frozen_string_literal: true

require_relative "constants"
require_relative "errors"

module Sashite
  module Sin
    # Parses SIN (Style Identifier Notation) strings.
    #
    # The parser uses byte-level validation to ensure security against
    # malformed input, Unicode lookalikes, and injection attacks.
    #
    # @example Parsing a valid SIN string
    #   Parser.parse("C")  # => { style: :C, side: :first }
    #   Parser.parse("c")  # => { style: :C, side: :second }
    #
    # @example Validation
    #   Parser.valid?("C")   # => true
    #   Parser.valid?("CC")  # => false
    #
    # @see https://sashite.dev/specs/sin/1.0.0/
    module Parser
      # Parses a SIN string into its components.
      #
      # @param input [String] The SIN string to parse
      # @return [Hash] Hash with :style and :side keys
      # @raise [Errors::Argument] If the input is invalid
      #
      # @example
      #   Parser.parse("C")  # => { style: :C, side: :first }
      #   Parser.parse("s")  # => { style: :S, side: :second }
      def self.parse(input)
        validate_input_type!(input)
        validate_not_empty!(input)
        validate_length!(input)

        byte = input.getbyte(0)
        validate_letter!(byte)

        extract_components(byte)
      end

      # Reports whether the input is a valid SIN string.
      #
      # @param input [String] The string to validate
      # @return [Boolean] true if valid, false otherwise
      #
      # @example
      #   Parser.valid?("C")   # => true
      #   Parser.valid?("c")   # => true
      #   Parser.valid?("")    # => false
      #   Parser.valid?("CC")  # => false
      def self.valid?(input)
        parse(input)
        true
      rescue Errors::Argument
        false
      end

      # @!group Private Class Methods

      # Validates that input is a String.
      #
      # @param input [Object] The input to validate
      # @raise [Errors::Argument] If input is not a String
      # @return [void]
      private_class_method def self.validate_input_type!(input)
        return if ::String === input

        raise Errors::Argument, Errors::Argument::Messages::MUST_BE_LETTER
      end

      # Validates that input is not empty.
      #
      # @param input [String] The input to validate
      # @raise [Errors::Argument] If input is empty
      # @return [void]
      private_class_method def self.validate_not_empty!(input)
        return unless input.empty?

        raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT
      end

      # Validates that input does not exceed maximum length.
      #
      # @param input [String] The input to validate
      # @raise [Errors::Argument] If input exceeds maximum length
      # @return [void]
      private_class_method def self.validate_length!(input)
        return if input.bytesize <= Constants::MAX_STRING_LENGTH

        raise Errors::Argument, Errors::Argument::Messages::INPUT_TOO_LONG
      end

      # Validates that byte is an ASCII letter.
      #
      # @param byte [Integer] The byte to validate
      # @raise [Errors::Argument] If byte is not a letter
      # @return [void]
      private_class_method def self.validate_letter!(byte)
        return if uppercase_letter?(byte) || lowercase_letter?(byte)

        raise Errors::Argument, Errors::Argument::Messages::MUST_BE_LETTER
      end

      # Extracts style and side from a validated byte.
      #
      # @param byte [Integer] A validated ASCII letter byte
      # @return [Hash] Hash with :style and :side keys
      private_class_method def self.extract_components(byte)
        if uppercase_letter?(byte)
          { style: byte.chr.to_sym, side: :first }
        else
          { style: byte.chr.upcase.to_sym, side: :second }
        end
      end

      # Reports whether byte is an uppercase ASCII letter (A-Z).
      #
      # @param byte [Integer] The byte to check
      # @return [Boolean] true if A-Z
      private_class_method def self.uppercase_letter?(byte)
        byte >= 0x41 && byte <= 0x5A
      end

      # Reports whether byte is a lowercase ASCII letter (a-z).
      #
      # @param byte [Integer] The byte to check
      # @return [Boolean] true if a-z
      private_class_method def self.lowercase_letter?(byte)
        byte >= 0x61 && byte <= 0x7A
      end

      # @!endgroup
    end
  end
end
