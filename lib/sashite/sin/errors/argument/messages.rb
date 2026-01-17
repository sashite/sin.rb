# frozen_string_literal: true

module Sashite
  module Sin
    module Errors
      class Argument < ::ArgumentError
        # Error messages for SIN parsing and validation.
        #
        # Provides centralized, immutable error message constants for consistent
        # error reporting across the library.
        #
        # @example Using an error message
        #   raise ArgumentError, Messages::EMPTY_INPUT
        #
        # @see https://sashite.dev/specs/sin/1.0.0/
        module Messages
          # Error message for empty input string.
          #
          # @return [String] Error message
          EMPTY_INPUT = "empty input"

          # Error message for input exceeding maximum length.
          #
          # @return [String] Error message
          INPUT_TOO_LONG = "input exceeds 1 character"

          # Error message for invalid character (not a letter).
          #
          # @return [String] Error message
          MUST_BE_LETTER = "must be a letter"

          # Error message for invalid style value.
          #
          # @return [String] Error message
          INVALID_STYLE = "invalid style"

          # Error message for invalid side value.
          #
          # @return [String] Error message
          INVALID_SIDE = "invalid side"
        end
      end
    end
  end
end
