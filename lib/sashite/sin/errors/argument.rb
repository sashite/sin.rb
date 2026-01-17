# frozen_string_literal: true

require_relative "argument/messages"

module Sashite
  module Sin
    module Errors
      # Namespace for ArgumentError-related constants and messages.
      #
      # Provides structured access to error messages used when raising
      # ArgumentError exceptions throughout the library.
      #
      # @example Raising an error with a message
      #   raise ArgumentError, Argument::Messages::EMPTY_INPUT
      #
      # @see Argument::Messages
      class Argument < ::ArgumentError
      end
    end
  end
end
