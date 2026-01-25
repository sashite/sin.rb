#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/sin/identifier"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
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

run_test("creates identifier with abbr and side") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "wrong abbr" unless id.abbr == :C
  raise "wrong side" unless id.side == :first
end

run_test("creates identifier for second player") do
  id = Sashite::Sin::Identifier.new(:S, :second)
  raise "wrong abbr" unless id.abbr == :S
  raise "wrong side" unless id.side == :second
end

run_test("creates identifier for all abbrs A-Z") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin::Identifier.new(abbr, :first)
    raise "wrong abbr for #{abbr}" unless id.abbr == abbr
  end
end

run_test("raises on invalid abbr") do
  Sashite::Sin::Identifier.new(:invalid, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR
end

run_test("raises on lowercase abbr symbol") do
  Sashite::Sin::Identifier.new(:c, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR
end

run_test("raises on non-symbol abbr") do
  Sashite::Sin::Identifier.new("C", :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR
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

run_test("to_s for all abbrs first player") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin::Identifier.new(abbr, :first)
    raise "wrong string for #{abbr}" unless id.to_s == abbr.to_s
  end
end

run_test("to_s for all abbrs second player") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin::Identifier.new(abbr, :second)
    raise "wrong string for #{abbr}" unless id.to_s == abbr.to_s.downcase
  end
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

run_test("same_abbr? returns true for same abbr") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "should be true" unless id1.same_abbr?(id2)
end

run_test("same_abbr? returns false for different abbr") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:S, :first)
  raise "should be false" if id1.same_abbr?(id2)
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

run_test("VALID_ABBRS contains 26 symbols") do
  raise "wrong count" unless Sashite::Sin::Identifier::VALID_ABBRS.size == 26
end

run_test("VALID_ABBRS contains :A through :Z") do
  (:A..:Z).each do |abbr|
    raise "missing #{abbr}" unless Sashite::Sin::Identifier::VALID_ABBRS.include?(abbr)
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

run_test("identifiers with different abbr are not equal") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:S, :first)
  raise "should not be equal" if id1 == id2
end

run_test("identifiers with different side are not equal") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "should not be equal" if id1 == id2
end

run_test("eql? behaves like ==") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :first)
  raise "should be eql" unless id1.eql?(id2)
end

run_test("hash is equal for equal identifiers") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :first)
  raise "hash should be equal" unless id1.hash == id2.hash
end

run_test("hash is different for different identifiers") do
  id1 = Sashite::Sin::Identifier.new(:C, :first)
  id2 = Sashite::Sin::Identifier.new(:C, :second)
  raise "hash should be different" if id1.hash == id2.hash
end

# ============================================================================
# INSPECT TESTS
# ============================================================================

puts
puts "Inspect:"

run_test("inspect returns readable representation") do
  id = Sashite::Sin::Identifier.new(:C, :first)
  raise "wrong inspect" unless id.inspect == "#<Sashite::Sin::Identifier C>"
end

run_test("inspect for second player") do
  id = Sashite::Sin::Identifier.new(:C, :second)
  raise "wrong inspect" unless id.inspect == "#<Sashite::Sin::Identifier c>"
end

puts
puts "All Identifier tests passed!"
puts
