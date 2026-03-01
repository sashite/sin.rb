# frozen_string_literal: true

require_relative "errors"
require_relative "identifier"

module Sashite
  module Sin
    # Parses SIN (Style Identifier Notation) strings.
    #
    # Implements a dual-path architecture for maximum performance:
    #
    # - {.safe_parse} validates and returns a cached Identifier or nil,
    #   without ever raising or allocating exception objects.
    # - {.parse} delegates to safe_parse and raises exactly once at the
    #   API boundary on failure.
    # - {.valid?} delegates to safe_parse and converts to boolean.
    #
    # All valid inputs resolve to a pre-instantiated flyweight Identifier
    # via a single byte-indexed Hash lookup.
    #
    # @example Parsing a valid SIN string
    #   Parser.parse("C")  # => #<Sashite::Sin::Identifier C>
    #   Parser.parse("c")  # => #<Sashite::Sin::Identifier c>
    #
    # @example Safe parsing
    #   Parser.safe_parse("C")   # => #<Sashite::Sin::Identifier C>
    #   Parser.safe_parse("1")   # => nil
    #   Parser.safe_parse(nil)   # => nil
    #
    # @example Validation
    #   Parser.valid?("C")   # => true
    #   Parser.valid?("CC")  # => false
    #
    # @see https://sashite.dev/specs/sin/1.0.0/
    module Parser
      # Parses a SIN string into a cached Identifier.
      #
      # Delegates to {.safe_parse} internally. On failure, raises a single
      # ArgumentError with a descriptive message.
      #
      # @param input [String] The SIN string to parse
      # @return [Identifier] A pre-instantiated, frozen Identifier
      # @raise [Errors::Argument] If the input is invalid
      #
      # @example
      #   Parser.parse("C")  # => #<Sashite::Sin::Identifier C>
      #   Parser.parse("s")  # => #<Sashite::Sin::Identifier s>
      def self.parse(input)
        safe_parse(input) || raise(Errors::Argument, error_message_for(input))
      end

      # Parses a SIN string without raising.
      #
      # Returns a cached Identifier on success, nil on failure.
      # Never allocates exception objects or captures backtraces.
      #
      # @param input [String] The string to parse
      # @return [Identifier, nil] A cached Identifier, or nil if invalid
      #
      # @example
      #   Parser.safe_parse("C")   # => #<Sashite::Sin::Identifier C>
      #   Parser.safe_parse("")    # => nil
      #   Parser.safe_parse(nil)   # => nil
      def self.safe_parse(input)
        return unless ::String === input
        return unless input.bytesize == 1

        Identifier::BYTE_POOL[input.getbyte(0)]
      end

      # Reports whether the input is a valid SIN string.
      #
      # Never raises; returns false for any invalid input including non-String.
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
        !safe_parse(input).nil?
      end

      # Determines the appropriate error message for an invalid input.
      #
      # @param input [Object] The invalid input
      # @return [String] A descriptive error message
      private_class_method def self.error_message_for(input)
        return Errors::Argument::Messages::MUST_BE_LETTER unless ::String === input
        return Errors::Argument::Messages::EMPTY_INPUT    if input.empty?
        return Errors::Argument::Messages::INPUT_TOO_LONG if input.bytesize > 1

        Errors::Argument::Messages::MUST_BE_LETTER
      end
    end
  end
end
