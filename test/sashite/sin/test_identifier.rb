#!/usr/bin/env ruby
# frozen_string_literal: true

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
puts "=== Identifier Tests ==="
puts

# ============================================================================
# CONSTRUCTOR TESTS
# ============================================================================

puts "Constructor:"

run_test("creates identifier with style and side") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "wrong style" unless id.style == :C
  raise "wrong side" unless id.side == :first
end

run_test("creates identifier for second player") do
  id = Sashite::Sin::Identifier.new(:S, :second)
  raise "wrong style" unless id.style == :S
  raise "wrong side" unless id.side == :second
end

run_test("creates identifier for all styles A-Z") do
  (:A..:Z).each do |style|
    id = Sashite::Sin::Identifier.new(style, :first)
    raise "wrong style for #{style}" unless id.style == style
  end
end

run_test("raises on invalid style") do
  Sashite::Sin::Identifier.new(:invalid, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE
end

run_test("raises on lowercase style symbol") do
  Sashite::Sin::Identifier.new(:c, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE
end

run_test("raises on non-symbol style") do
  Sashite::Sin::Identifier.new("C", :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE
end

run_test("raises on invalid side") do
  Sashite::Sin::Identifier.new(:C, :invalid)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE
end

run_test("raises on non-symbol side") do
  Sashite::Sin::Identifier.new(:C, "first")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE
end

# ============================================================================
# IMMUTABILITY TESTS
# ============================================================================

puts
puts "Immutability:"

run_test("identifier is frozen after creation") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "should be frozen" unless id.frozen?
end

# ============================================================================
# STRING CONVERSION TESTS
# ============================================================================

puts
puts "String conversion:"

run_test("to_s returns uppercase for first player") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "wrong string" unless id.to_s == "C"
end

run_test("to_s returns lowercase for second player") do
  id = Sashite::Sin::Identifier.new(:C, :second)
  raise "wrong string" unless id.to_s == "c"
end

run_test("letter returns uppercase for first player") do
  id = Sashite::Sin::Identifier.new(:S, :first)
  raise "wrong letter" unless id.letter == "S"
end

run_test("letter returns lowercase for second player") do
  id = Sashite::Sin::Identifier.new(:S, :second)
  raise "wrong letter" unless id.letter == "s"
end

run_test("to_s for all styles first player") do
  (:A..:Z).each do |style|
    id = Sashite::Sin::Identifier.new(style, :first)
    raise "wrong string for #{style}" unless id.to_s == style.to_s
  end
end

run_test("to_s for all styles second player") do
  (:A..:Z).each do |style|
    id = Sashite::Sin::Identifier.new(style, :second)
    raise "wrong string for #{style}" unless id.to_s == style.to_s.downcase
  end
end

# ============================================================================
# SIDE TRANSFORMATION TESTS
# ============================================================================

puts
puts "Side transformations:"

run_test("flip changes first to second") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  flipped = id.flip
  raise "wrong side" unless flipped.side == :second
  raise "style should be unchanged" unless flipped.style == :C
end

run_test("flip changes second to first") do
  id = Sashite::Sin::Identifier.new(:C, :second)
  flipped = id.flip
  raise "wrong side" unless flipped.side == :first
end

run_test("flip does not modify original") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  id.flip
  raise "original should be unchanged" unless id.side == :first
end

run_test("flip returns new object") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  flipped = id.flip
  raise "should be different object" if id.equal?(flipped)
end

# ============================================================================
# ATTRIBUTE TRANSFORMATION TESTS
# ============================================================================

puts
puts "Attribute transformations:"

run_test("with_style changes style") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  changed = id.with_style(:S)
  raise "wrong style" unless changed.style == :S
  raise "side should be unchanged" unless changed.side == :first
end

run_test("with_style returns self if same style") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  changed = id.with_style(:C)
  raise "should return same object" unless id.equal?(changed)
end

run_test("with_style does not modify original") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  id.with_style(:S)
  raise "original should be unchanged" unless id.style == :C
end

run_test("with_style raises on invalid style") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  id.with_style(:invalid)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_STYLE
end

run_test("with_side changes side") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  changed = id.with_side(:second)
  raise "wrong side" unless changed.side == :second
  raise "style should be unchanged" unless changed.style == :C
end

run_test("with_side returns self if same side") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  changed = id.with_side(:first)
  raise "should return same object" unless id.equal?(changed)
end

run_test("with_side does not modify original") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  id.with_side(:second)
  raise "original should be unchanged" unless id.side == :first
end

run_test("with_side raises on invalid side") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  id.with_side(:invalid)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE
end

# ============================================================================
# SIDE QUERY TESTS
# ============================================================================

puts
puts "Side queries:"

run_test("first_player? returns true for first") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "should be true" unless id.first_player?
end

run_test("first_player? returns false for second") do
  id = Sashite::Sin::Identifier.new(:C, :second)
  raise "should be false" if id.first_player?
end

run_test("second_player? returns true for second") do
  id = Sashite::Sin::Identifier.new(:C, :second)
  raise "should be true" unless id.second_player?
end

run_test("second_player? returns false for first") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "should be false" if id.second_player?
end

# ============================================================================
# COMPARISON QUERY TESTS
# ============================================================================

puts
puts "Comparison queries:"

run_test("same_style? returns true for same style") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "should be true" unless id1.same_style?(id2)
end

run_test("same_style? returns false for different style") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:S, :first)
  raise "should be false" if id1.same_style?(id2)
end

run_test("same_side? returns true for same side") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:S, :first)
  raise "should be true" unless id1.same_side?(id2)
end

run_test("same_side? returns false for different side") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "should be false" if id1.same_side?(id2)
end

# ============================================================================
# CONSTANTS TESTS
# ============================================================================

puts
puts "Constants:"

run_test("VALID_STYLES contains 26 symbols") do
  raise "wrong count" unless Sashite::Sin::Identifier::VALID_STYLES.size == 26
end

run_test("VALID_STYLES contains :A through :Z") do
  (:A..:Z).each do |style|
    raise "missing #{style}" unless Sashite::Sin::Identifier::VALID_STYLES.include?(style)
  end
end

run_test("VALID_SIDES contains :first and :second") do
  raise "missing :first" unless Sashite::Sin::Identifier::VALID_SIDES.include?(:first)
  raise "missing :second" unless Sashite::Sin::Identifier::VALID_SIDES.include?(:second)
  raise "wrong count" unless Sashite::Sin::Identifier::VALID_SIDES.size == 2
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

run_test("identifiers with same attributes are equal") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :first)
  raise "should be equal" unless id1 == id2
end

run_test("identifiers with different style are not equal") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:S, :first)
  raise "should not be equal" if id1 == id2
end

run_test("identifiers with different side are not equal") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "should not be equal" if id1 == id2
end

puts
puts "All Identifier tests passed!"
puts
