# frozen_string_literal: true

module Sashite
  module Sin
    # Constants for the SIN (Style Identifier Notation) specification.
    #
    # Provides public-facing domain constants and pre-computed lookup tables
    # used internally for zero-allocation parsing.
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

      # Pre-computed byte → uppercase Symbol lookup table.
      #
      # Maps every valid ASCII letter byte (A-Z, a-z) to its uppercase Symbol
      # abbreviation. Used by the parser for O(1) extraction with no intermediate
      # String allocation.
      #
      # @example
      #   BYTE_TO_ABBR[0x43]  # => :C  (byte for 'C')
      #   BYTE_TO_ABBR[0x63]  # => :C  (byte for 'c')
      #   BYTE_TO_ABBR[0x31]  # => nil  (byte for '1')
      #
      # @return [Hash{Integer => Symbol}] Frozen byte-to-symbol mapping
      BYTE_TO_ABBR = {}.tap { |h|
        (0x41..0x5A).each { |b| h[b] = b.chr.to_sym }
        (0x61..0x7A).each { |b| h[b] = (b - 32).chr.to_sym }
      }.freeze

      # Pre-computed byte → side lookup table.
      #
      # Maps every valid ASCII letter byte to its corresponding side.
      # Uppercase letters map to :first, lowercase to :second.
      #
      # @example
      #   BYTE_TO_SIDE[0x43]  # => :first   (byte for 'C')
      #   BYTE_TO_SIDE[0x63]  # => :second  (byte for 'c')
      #   BYTE_TO_SIDE[0x31]  # => nil      (byte for '1')
      #
      # @return [Hash{Integer => Symbol}] Frozen byte-to-side mapping
      BYTE_TO_SIDE = {}.tap { |h|
        (0x41..0x5A).each { |b| h[b] = :first }
        (0x61..0x7A).each { |b| h[b] = :second }
      }.freeze
    end
  end
end
