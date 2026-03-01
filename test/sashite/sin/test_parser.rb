#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/sin"

puts
puts "=== Parser Tests ==="
puts

# ============================================================================
# PARSE - VALID INPUTS (UPPERCASE)
# ============================================================================

puts "parse - valid uppercase letters:"

Test("parses uppercase letter 'C'") do
  result = Sashite::Sin::Parser.parse("C")
  raise "wrong class" unless Sashite::Sin::Identifier === result
  raise "wrong abbr" unless result.abbr == :C
  raise "wrong side" unless result.side == :first
end

Test("parses uppercase letter 'S'") do
  result = Sashite::Sin::Parser.parse("S")
  raise "wrong abbr" unless result.abbr == :S
  raise "wrong side" unless result.side == :first
end

Test("parses all uppercase letters A-Z") do
  ("A".."Z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    raise "wrong abbr for #{letter}" unless result.abbr == letter.to_sym
    raise "wrong side for #{letter}" unless result.side == :first
  end
end

# ============================================================================
# PARSE - VALID INPUTS (LOWERCASE)
# ============================================================================

puts
puts "parse - valid lowercase letters:"

Test("parses lowercase letter 'c'") do
  result = Sashite::Sin::Parser.parse("c")
  raise "wrong abbr" unless result.abbr == :C
  raise "wrong side" unless result.side == :second
end

Test("parses lowercase letter 's'") do
  result = Sashite::Sin::Parser.parse("s")
  raise "wrong abbr" unless result.abbr == :S
  raise "wrong side" unless result.side == :second
end

Test("parses all lowercase letters a-z") do
  ("a".."z").each do |letter|
    result = Sashite::Sin::Parser.parse(letter)
    raise "wrong abbr for #{letter}" unless result.abbr == letter.upcase.to_sym
    raise "wrong side for #{letter}" unless result.side == :second
  end
end

# ============================================================================
# PARSE - FLYWEIGHT IDENTITY
# ============================================================================

puts
puts "parse - flyweight identity:"

Test("returns cached instance") do
  id1 = Sashite::Sin::Parser.parse("C")
  id2 = Sashite::Sin::Parser.parse("C")
  raise "should be same object" unless id1.equal?(id2)
end

Test("parse result is same object as fetch") do
  id1 = Sashite::Sin::Parser.parse("c")
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "should be same object" unless id1.equal?(id2)
end

# ============================================================================
# SAFE_PARSE - VALID INPUTS
# ============================================================================

puts
puts "safe_parse - valid inputs:"

Test("returns Identifier for uppercase") do
  result = Sashite::Sin::Parser.safe_parse("C")
  raise "wrong class" unless Sashite::Sin::Identifier === result
  raise "wrong abbr" unless result.abbr == :C
  raise "wrong side" unless result.side == :first
end

Test("returns Identifier for lowercase") do
  result = Sashite::Sin::Parser.safe_parse("c")
  raise "wrong abbr" unless result.abbr == :C
  raise "wrong side" unless result.side == :second
end

Test("returns cached instance") do
  id1 = Sashite::Sin::Parser.safe_parse("S")
  id2 = Sashite::Sin::Parser.safe_parse("S")
  raise "should be same object" unless id1.equal?(id2)
end

# ============================================================================
# SAFE_PARSE - INVALID INPUTS (RETURNS NIL, NEVER RAISES)
# ============================================================================

puts
puts "safe_parse - invalid inputs (returns nil):"

Test("returns nil for empty string") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("").nil?
end

Test("returns nil for multiple characters") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("CC").nil?
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("abc").nil?
end

Test("returns nil for digit") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("1").nil?
end

Test("returns nil for symbol characters") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("+").nil?
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("-").nil?
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse("^").nil?
end

Test("returns nil for nil input") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse(nil).nil?
end

Test("returns nil for integer input") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse(123).nil?
end

Test("returns nil for symbol input") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse(:C).nil?
end

Test("returns nil for array input") do
  raise "should be nil" unless Sashite::Sin::Parser.safe_parse([:C]).nil?
end

# ============================================================================
# VALID? METHOD
# ============================================================================

puts
puts "valid? method:"

Test("returns true for valid uppercase letters") do
  ("A".."Z").each do |letter|
    raise "should be valid: #{letter}" unless Sashite::Sin::Parser.valid?(letter)
  end
end

Test("returns true for valid lowercase letters") do
  ("a".."z").each do |letter|
    raise "should be valid: #{letter}" unless Sashite::Sin::Parser.valid?(letter)
  end
end

Test("returns false for empty string") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("")
end

Test("returns false for multiple characters") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("CC")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("abc")
end

Test("returns false for digits") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("1")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("0")
end

Test("returns false for symbols") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("+")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("-")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("^")
end

Test("returns false for nil") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(nil)
end

# ============================================================================
# PARSE - ERROR CASES (EMPTY INPUT)
# ============================================================================

puts
puts "parse - error cases (empty input):"

Test("raises on empty string") do
  Sashite::Sin::Parser.parse("")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::EMPTY_INPUT
end

# ============================================================================
# PARSE - ERROR CASES (INPUT TOO LONG)
# ============================================================================

puts
puts "parse - error cases (input too long):"

Test("raises on two characters") do
  Sashite::Sin::Parser.parse("CC")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG
end

Test("raises on many characters") do
  Sashite::Sin::Parser.parse("invalid")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INPUT_TOO_LONG
end

# ============================================================================
# PARSE - ERROR CASES (MUST BE LETTER)
# ============================================================================

puts
puts "parse - error cases (must be letter):"

Test("raises on digit") do
  Sashite::Sin::Parser.parse("1")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

Test("raises on plus sign") do
  Sashite::Sin::Parser.parse("+")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

Test("raises on minus sign") do
  Sashite::Sin::Parser.parse("-")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

Test("raises on caret") do
  Sashite::Sin::Parser.parse("^")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

Test("raises on space") do
  Sashite::Sin::Parser.parse(" ")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

Test("raises on non-string input") do
  Sashite::Sin::Parser.parse(nil)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::MUST_BE_LETTER
end

# ============================================================================
# SECURITY TESTS - NULL BYTE INJECTION
# ============================================================================

puts
puts "Security - null byte injection:"

Test("rejects null byte alone") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x00")
end

Test("rejects letter followed by null byte") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\x00")
end

Test("rejects null byte followed by letter") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x00C")
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

Test("rejects newline") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\n")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\n")
end

Test("rejects carriage return") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\r")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\r")
end

Test("rejects tab") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\t")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\t")
end

Test("rejects other control characters") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x01") # SOH
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x1b") # ESC
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\x7f") # DEL
end

# ============================================================================
# SECURITY TESTS - UNICODE LOOKALIKES
# ============================================================================

puts
puts "Security - Unicode lookalikes:"

Test("rejects Cyrillic lookalikes") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\x9A")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\xB0")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xD0\xA1")
end

Test("rejects Greek lookalikes") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xCE\x91")
end

Test("rejects full-width characters") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBC\xA3")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBD\x83")
end

# ============================================================================
# SECURITY TESTS - COMBINING CHARACTERS
# ============================================================================

puts
puts "Security - combining characters:"

Test("rejects combining acute accent") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xCC\x81")
end

Test("rejects combining diaeresis") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xCC\x88")
end

# ============================================================================
# SECURITY TESTS - ZERO-WIDTH CHARACTERS
# ============================================================================

puts
puts "Security - zero-width characters:"

Test("rejects zero-width space") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xE2\x80\x8B")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("C\xE2\x80\x8B")
end

Test("rejects zero-width non-joiner") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xE2\x80\x8C")
end

Test("rejects BOM") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBB\xBF")
  raise "should be invalid" if Sashite::Sin::Parser.valid?("\xEF\xBB\xBFC")
end

# ============================================================================
# SECURITY TESTS - NON-STRING INPUT
# ============================================================================

puts
puts "Security - non-string input:"

Test("rejects nil") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(nil)
end

Test("rejects integer") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(123)
end

Test("rejects array") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?([:C])
end

Test("rejects hash") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?({ abbr: :C })
end

Test("rejects symbol") do
  raise "should be invalid" if Sashite::Sin::Parser.valid?(:C)
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip tests:"

Test("round-trip uppercase letters") do
  ("A".."Z").each do |letter|
    identifier = Sashite::Sin::Parser.parse(letter)
    raise "round-trip failed for #{letter}" unless identifier.to_s == letter
  end
end

Test("round-trip lowercase letters") do
  ("a".."z").each do |letter|
    identifier = Sashite::Sin::Parser.parse(letter)
    raise "round-trip failed for #{letter}" unless identifier.to_s == letter
  end
end

puts
puts "All Parser tests passed!"
puts
