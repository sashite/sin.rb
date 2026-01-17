#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/sin/errors"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✔"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "=== Errors Tests ==="
puts

# ============================================================================
# PARSING ERROR MESSAGES
# ============================================================================

puts "Parsing error messages:"

run_test("EMPTY_INPUT is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT == "empty input"
end

run_test("INPUT_TOO_LONG is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG == "input exceeds 1 character"
end

run_test("MUST_BE_LETTER is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER == "must be a letter"
end

# ============================================================================
# VALIDATION ERROR MESSAGES
# ============================================================================

puts
puts "Validation error messages:"

run_test("INVALID_STYLE is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE == "invalid style"
end

run_test("INVALID_SIDE is defined") do
  raise "wrong value" unless Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE == "invalid side"
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("Argument inherits from ArgumentError") do
  raise "wrong inheritance" unless Sashite::Sin::Errors::Argument < ArgumentError
end

run_test("Argument can be raised with message") do
  raise Sashite::Sin::Errors::Argument, Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == "empty input"
end

run_test("Argument can be rescued as ArgumentError") do
  raise Sashite::Sin::Errors::Argument, "test"
rescue ArgumentError => e
  raise "should be rescuable as ArgumentError" unless e.message == "test"
end

# ============================================================================
# ERROR MESSAGES ARE FROZEN
# ============================================================================

puts
puts "Immutability:"

run_test("EMPTY_INPUT is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT.frozen?
end

run_test("INPUT_TOO_LONG is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG.frozen?
end

run_test("MUST_BE_LETTER is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER.frozen?
end

run_test("INVALID_STYLE is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE.frozen?
end

run_test("INVALID_SIDE is frozen") do
  raise "should be frozen" unless Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE.frozen?
end

puts
puts "All Errors tests passed!"
puts
