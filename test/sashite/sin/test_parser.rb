#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/sin/parser"
require_relative "../../../lib/sashite/sin/identifier"

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
puts "=== Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - UPPERCASE LETTERS
# ============================================================================

puts "Valid inputs - uppercase letters:"

run_test("parses uppercase letter 'C'") do
  result = Sashite::Sin::Parser.parse("C")
  raise "wrong style" unless result[:style] == :C
  raise "wrong side" unless result[:side] == :first
end

run_test("parses uppercase letter 'S'") do
  result = Sashite::Sin::Parser.parse("S")
  raise "wrong style" unless result[:style] == :S
  raise "wrong side" unless result[:side] == :first
end

run_test("parses all uppercase letters A-Z") do
  ("A".."Z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    raise "wrong style for #{letter}" unless result[:style] == letter.to_sym
    raise "wrong side for #{letter}" unless result[:side] == :first
  end
end

# ============================================================================
# VALID INPUTS - LOWERCASE LETTERS
# ============================================================================

puts
puts "Valid inputs - lowercase letters:"

run_test("parses lowercase letter 'c'") do
  result = Sashite::Sin::Parser.parse("c")
  raise "wrong style" unless result[:style] == :C
  raise "wrong side" unless result[:side] == :second
end

run_test("parses lowercase letter 's'") do
  result = Sashite::Sin::Parser.parse("s")
  raise "wrong style" unless result[:style] == :S
  raise "wrong side" unless result[:side] == :second
end

run_test("parses all lowercase letters a-z") do
  ("a".."z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    raise "wrong style for #{letter}" unless result[:style] == letter.upcase.to_sym
    raise "wrong side for #{letter}" unless result[:side] == :second
  end
end

# ============================================================================
# VALID? METHOD
# ============================================================================

puts
puts "valid? method:"

run_test("returns true for valid uppercase letters") do
  ("A".."Z").each do |letter|
    raise "should be valid: #{letter}" unless Sashite::Sin::Parser.valid?(letter)
  end
end

run_test("returns true for valid lowercase letters") do
  ("a".."z").each do |letter|
    raise "should be valid: #{letter}" unless Sashite::Sin::Parser.valid?(letter)
  end
end

run_test("returns false for empty string") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("")
end

run_test("returns false for multiple characters") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("CC")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("abc")
end

run_test("returns false for digits") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("1")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("0")
end

run_test("returns false for symbols") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("+")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("-")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("^")
end

run_test("returns false for nil") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(nil)
end

# ============================================================================
# ERROR CASES - EMPTY INPUT
# ============================================================================

puts
puts "Error cases - empty input:"

run_test("raises on empty string") do
  Sashite::Sin::Parser.parse("")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT
end

# ============================================================================
# ERROR CASES - INPUT TOO LONG
# ============================================================================

puts
puts "Error cases - input too long:"

run_test("raises on two characters") do
  Sashite::Sin::Parser.parse("CC")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG
end

run_test("raises on many characters") do
  Sashite::Sin::Parser.parse("invalid")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG
end

# ============================================================================
# ERROR CASES - MUST BE LETTER
# ============================================================================

puts
puts "Error cases - must be letter:"

run_test("raises on digit") do
  Sashite::Sin::Parser.parse("1")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

run_test("raises on plus sign") do
  Sashite::Sin::Parser.parse("+")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

run_test("raises on minus sign") do
  Sashite::Sin::Parser.parse("-")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

run_test("raises on caret") do
  Sashite::Sin::Parser.parse("^")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

run_test("raises on space") do
  Sashite::Sin::Parser.parse(" ")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

# ============================================================================
# SECURITY TESTS - NULL BYTE INJECTION
# ============================================================================

puts
puts "Security - null byte injection:"

run_test("rejects null byte alone") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x00")
end

run_test("rejects letter followed by null byte") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\x00")
end

run_test("rejects null byte followed by letter") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x00C")
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

run_test("rejects newline") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\n")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\n")
end

run_test("rejects carriage return") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\r")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\r")
end

run_test("rejects tab") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\t")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\t")
end

run_test("rejects other control characters") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x01") # SOH
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x1b") # ESC
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x7f") # DEL
end

# ============================================================================
# SECURITY TESTS - UNICODE LOOKALIKES
# ============================================================================

puts
puts "Security - Unicode lookalikes:"

run_test("rejects Cyrillic lookalikes") do
  # Cyrillic 'К' (U+041A) looks like Latin 'K'
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\x9A")
  # Cyrillic 'а' (U+0430) looks like Latin 'a'
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\xB0")
  # Cyrillic 'С' (U+0421) looks like Latin 'C'
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\xA1")
end

run_test("rejects Greek lookalikes") do
  # Greek 'Α' (U+0391) looks like Latin 'A'
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xCE\x91")
end

run_test("rejects full-width characters") do
  # Full-width 'C' (U+FF23)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBC\xA3")
  # Full-width 'c' (U+FF43)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBD\x83")
end

# ============================================================================
# SECURITY TESTS - COMBINING CHARACTERS
# ============================================================================

puts
puts "Security - combining characters:"

run_test("rejects combining acute accent") do
  # 'C' + combining acute accent (U+0301)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xCC\x81")
end

run_test("rejects combining diaeresis") do
  # 'C' + combining diaeresis (U+0308)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xCC\x88")
end

# ============================================================================
# SECURITY TESTS - ZERO-WIDTH CHARACTERS
# ============================================================================

puts
puts "Security - zero-width characters:"

run_test("rejects zero-width space") do
  # Zero-width space (U+200B)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xE2\x80\x8B")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xE2\x80\x8B")
end

run_test("rejects zero-width non-joiner") do
  # Zero-width non-joiner (U+200C)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xE2\x80\x8C")
end

run_test("rejects BOM") do
  # Byte order mark (U+FEFF)
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBB\xBF")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBB\xBFC")
end

# ============================================================================
# SECURITY TESTS - NON-STRING INPUT
# ============================================================================

puts
puts "Security - non-string input:"

run_test("rejects nil") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(nil)
end

run_test("rejects integer") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(123)
end

run_test("rejects array") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?([:C])
end

run_test("rejects hash") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?({ style: :C })
end

run_test("rejects symbol") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(:C)
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip tests:"

run_test("round-trip uppercase letters") do
  ("A".."Z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    identifier = Sashite::Sin::Identifier.new(result.fetch(:style), result.fetch(:side))
    raise "round-trip failed for #{letter}" unless identifier.to_s == letter
  end
end

run_test("round-trip lowercase letters") do
  ("a".."z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    identifier = Sashite::Sin::Identifier.new(result.fetch(:style), result.fetch(:side))
    raise "round-trip failed for #{letter}" unless identifier.to_s == letter
  end
end

puts
puts "All Parser tests passed!"
puts
