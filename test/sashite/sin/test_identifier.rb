#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/sin"

puts
puts "=== Identifier Tests ==="
puts

# ============================================================================
# PRIVATE CONSTRUCTOR
# ============================================================================

puts "Private constructor:"

Test("new is private") do
  Sashite::Sin::Identifier.new(:C, :first)
  raise "should have raised NoMethodError"
rescue NoMethodError
  # expected
end

# ============================================================================
# FETCH TESTS
# ============================================================================

puts
puts "Fetch:"

Test("fetches identifier with abbr and side") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "wrong abbr" unless id.abbr == :C
  raise "wrong side" unless id.side == :first
end

Test("fetches identifier for second player") do
  id = Sashite::Sin.fetch(:S, :second)
  raise "wrong abbr" unless id.abbr == :S
  raise "wrong side" unless id.side == :second
end

Test("fetches identifier for all abbrs A-Z") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin.fetch(abbr, :first)
    raise "wrong abbr for #{abbr}" unless id.abbr == abbr
  end
end

Test("raises on invalid abbr") do
  Sashite::Sin.fetch(:invalid, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR
end

Test("raises on lowercase abbr symbol") do
  Sashite::Sin.fetch(:c, :first)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_ABBR
end

Test("raises on invalid side") do
  Sashite::Sin.fetch(:C, :invalid)
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Sin::Errors::Argument::Messages::INVALID_SIDE
end

# ============================================================================
# FLYWEIGHT IDENTITY
# ============================================================================

puts
puts "Flyweight identity:"

Test("fetch returns same object for same arguments") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :first)
  raise "should be same object" unless id1.equal?(id2)
end

Test("parse and fetch return same object") do
  id1 = Sashite::Sin.parse("C")
  id2 = Sashite::Sin.fetch(:C, :first)
  raise "should be same object" unless id1.equal?(id2)
end

Test("safe_parse and fetch return same object") do
  id1 = Sashite::Sin.safe_parse("c")
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "should be same object" unless id1.equal?(id2)
end

Test("pool contains exactly 52 instances") do
  raise "wrong pool size" unless Sashite::Sin::Identifier::POOL.size == 52
end

Test("byte pool contains exactly 52 entries") do
  raise "wrong byte pool size" unless Sashite::Sin::Identifier::BYTE_POOL.size == 52
end

# ============================================================================
# IMMUTABILITY TESTS
# ============================================================================

puts
puts "Immutability:"

Test("identifier is frozen") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be frozen" unless id.frozen?
end

Test("pool is frozen") do
  raise "should be frozen" unless Sashite::Sin::Identifier::POOL.frozen?
end

Test("byte pool is frozen") do
  raise "should be frozen" unless Sashite::Sin::Identifier::BYTE_POOL.frozen?
end

# ============================================================================
# STRING CONVERSION TESTS
# ============================================================================

puts
puts "String conversion:"

Test("to_s returns uppercase for first player") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "wrong string" unless id.to_s == "C"
end

Test("to_s returns lowercase for second player") do
  id = Sashite::Sin.fetch(:C, :second)
  raise "wrong string" unless id.to_s == "c"
end

Test("to_s for all abbrs first player") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin.fetch(abbr, :first)
    raise "wrong string for #{abbr}" unless id.to_s == abbr.to_s
  end
end

Test("to_s for all abbrs second player") do
  (:A..:Z).each do |abbr|
    id = Sashite::Sin.fetch(abbr, :second)
    raise "wrong string for #{abbr}" unless id.to_s == abbr.to_s.downcase
  end
end

Test("to_s returns frozen string") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be frozen" unless id.to_s.frozen?
end

Test("to_s returns same string object each call") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be same object" unless id.to_s.equal?(id.to_s)
end

# ============================================================================
# SIDE QUERY TESTS
# ============================================================================

puts
puts "Side queries:"

Test("first_player? returns true for first") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be true" unless id.first_player?
end

Test("first_player? returns false for second") do
  id = Sashite::Sin.fetch(:C, :second)
  raise "should be false" if id.first_player?
end

Test("second_player? returns true for second") do
  id = Sashite::Sin.fetch(:C, :second)
  raise "should be true" unless id.second_player?
end

Test("second_player? returns false for first") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be false" if id.second_player?
end

# ============================================================================
# COMPARISON QUERY TESTS
# ============================================================================

puts
puts "Comparison queries:"

Test("same_abbr? returns true for same abbr") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "should be true" unless id1.same_abbr?(id2)
end

Test("same_abbr? returns false for different abbr") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:S, :first)
  raise "should be false" if id1.same_abbr?(id2)
end

Test("same_side? returns true for same side") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:S, :first)
  raise "should be true" unless id1.same_side?(id2)
end

Test("same_side? returns false for different side") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "should be false" if id1.same_side?(id2)
end

# ============================================================================
# CONSTANTS TESTS
# ============================================================================

puts
puts "Constants:"

Test("VALID_ABBRS contains 26 symbols") do
  raise "wrong count" unless Sashite::Sin::Identifier::VALID_ABBRS.size == 26
end

Test("VALID_ABBRS contains :A through :Z") do
  (:A..:Z).each do |abbr|
    raise "missing #{abbr}" unless Sashite::Sin::Identifier::VALID_ABBRS.include?(abbr)
  end
end

Test("VALID_SIDES contains :first and :second") do
  raise "missing :first" unless Sashite::Sin::Identifier::VALID_SIDES.include?(:first)
  raise "missing :second" unless Sashite::Sin::Identifier::VALID_SIDES.include?(:second)
  raise "wrong count" unless Sashite::Sin::Identifier::VALID_SIDES.size == 2
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

Test("identifiers with same attributes are equal") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :first)
  raise "should be equal" unless id1 == id2
end

Test("identifiers with different abbr are not equal") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:S, :first)
  raise "should not be equal" if id1 == id2
end

Test("identifiers with different side are not equal") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "should not be equal" if id1 == id2
end

Test("eql? behaves like ==") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :first)
  raise "should be eql" unless id1.eql?(id2)
end

Test("hash is equal for equal identifiers") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :first)
  raise "hash should be equal" unless id1.hash == id2.hash
end

Test("hash is different for different identifiers") do
  id1 = Sashite::Sin.fetch(:C, :first)
  id2 = Sashite::Sin.fetch(:C, :second)
  raise "hash should be different" if id1.hash == id2.hash
end

# ============================================================================
# INSPECT TESTS
# ============================================================================

puts
puts "Inspect:"

Test("inspect returns readable representation") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "wrong inspect" unless id.inspect == "#<Sashite::Sin::Identifier C>"
end

Test("inspect for second player") do
  id = Sashite::Sin.fetch(:C, :second)
  raise "wrong inspect" unless id.inspect == "#<Sashite::Sin::Identifier c>"
end

Test("inspect returns frozen string") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be frozen" unless id.inspect.frozen?
end

Test("inspect returns same string object each call") do
  id = Sashite::Sin.fetch(:C, :first)
  raise "should be same object" unless id.inspect.equal?(id.inspect)
end

puts
puts "All Identifier tests passed!"
puts
