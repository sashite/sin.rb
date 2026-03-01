#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/sin/errors"

puts
puts "=== Errors Tests ==="
puts

# ============================================================================
# PARSING ERROR MESSAGES
# ============================================================================

puts "Parsing error messages:"

Test("EMPTY_INPUT is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT == "empty input"
end

Test("INPUT_TOO_LONG is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG == "input exceeds 1 character"
end

Test("MUST_BE_LETTER is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER == "must be a letter"
end

# ============================================================================
# VALIDATION ERROR MESSAGES
# ============================================================================

puts
puts "Validation error messages:"

Test("INVALID_ABBR is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR == "invalid abbr"
end

Test("INVALID_SIDE is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE == "invalid side"
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

Test("Argument inherits from ArgumentError") do
  raise "wrong inheritance" unless Sashite::Sin::Errors::Argument < ArgumentError
end

Test("Argument can be raised with message") do
  raise Sashite::Sin::Errors::Argument, Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == "empty input"
end

Test("Argument can be rescued as ArgumentError") do
  raise Sashite::Sin::Errors::Argument, "test"
rescue ArgumentError => e
  raise "should be rescuable as ArgumentError" unless e.message == "test"
end

# ============================================================================
# ERROR MESSAGES ARE FROZEN
# ============================================================================

puts
puts "Immutability:"

Test("EMPTY_INPUT is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT.frozen?
end

Test("INPUT_TOO_LONG is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG.frozen?
end

Test("MUST_BE_LETTER is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER.frozen?
end

Test("INVALID_ABBR is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR.frozen?
end

Test("INVALID_SIDE is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE.frozen?
end

puts
puts "All Errors tests passed!"
puts
