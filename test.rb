# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Sin (Style Identifier Notation)
#
# Tests the SIN implementation for Ruby, focusing on the modern object-oriented API
# with the Identifier class using family-based attributes conforming to SIN v1.0.0 specification.
#
# This test assumes the existence of:
# - lib/sashite-sin.rb

require_relative "lib/sashite-sin"
require "set"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Sin (Style Identifier Notation) v1.0.0"
puts

# Test basic validation (module level)
run_test("Module SIN validation accepts valid notations") do
  valid_sins = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]

  valid_sins.each do |sin|
    raise "#{sin.inspect} should be valid" unless Sashite::Sin.valid?(sin)
  end
end

run_test("Module SIN validation rejects invalid notations") do
  invalid_sins = [
    "", "AA", "Aa", "aA", "aa", "AB", "ab", "Chess", "CHESS", "chess",
    "123", "1", "2", "A1", "1A", "A2", "2A", "B1", "1B",
    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    " A", "A ", "A B", "A-B", "A_B", " ", "\t", "\n",
    "α", "β", "♕", "♔", "🀄", "象", "將", "CHESS", "SHOGI"
  ]

  invalid_sins.each do |sin|
    raise "#{sin.inspect} should be invalid" if Sashite::Sin.valid?(sin)
  end
end

run_test("Module SIN validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Sin.valid?(input)
  end
end

# Test module parse method delegates to Identifier
run_test("Module parse delegates to Identifier class") do
  sin_string = "C"
  identifier = Sashite::Sin.parse(sin_string)

  raise "parse should return Identifier instance" unless identifier.is_a?(Sashite::Sin::Identifier)
  raise "identifier should have correct SIN string" unless identifier.to_s == sin_string
end

# Test module identifier factory method
run_test("Module identifier factory method creates correct instances") do
  identifier = Sashite::Sin.identifier(:C, :first)

  raise "identifier factory should return Identifier instance" unless identifier.is_a?(Sashite::Sin::Identifier)
  raise "identifier should have correct family" unless identifier.family == :C
  raise "identifier should have correct side" unless identifier.side == :first
  raise "identifier should have correct SIN string" unless identifier.to_s == "C"
end

# Test the Identifier class with family-based API
run_test("Identifier.parse creates correct instances with family attributes") do
  test_cases = {
    "C" => { family: :C, side: :first },
    "c" => { family: :C, side: :second },
    "S" => { family: :S, side: :first },
    "s" => { family: :S, side: :second },
    "X" => { family: :X, side: :first },
    "x" => { family: :X, side: :second }
  }

  test_cases.each do |sin_string, expected|
    identifier = Sashite::Sin.parse(sin_string)

    raise "#{sin_string}: wrong family" unless identifier.family == expected[:family]
    raise "#{sin_string}: wrong side" unless identifier.side == expected[:side]
  end
end

run_test("Identifier constructor with family parameters") do
  test_cases = [
    [:C, :first, "C"],
    [:C, :second, "c"],
    [:S, :first, "S"],
    [:S, :second, "s"],
    [:X, :first, "X"],
    [:X, :second, "x"]
  ]

  test_cases.each do |family, side, expected_sin|
    identifier = Sashite::Sin::Identifier.new(family, side)

    raise "family should be #{family}" unless identifier.family == family
    raise "side should be #{side}" unless identifier.side == side
    raise "SIN string should be #{expected_sin}" unless identifier.to_s == expected_sin
  end
end

run_test("Identifier to_s returns correct SIN string") do
  test_cases = [
    [:C, :first, "C"],
    [:C, :second, "c"],
    [:S, :first, "S"],
    [:S, :second, "s"],
    [:X, :first, "X"],
    [:X, :second, "x"]
  ]

  test_cases.each do |family, side, expected|
    identifier = Sashite::Sin::Identifier.new(family, side)
    result = identifier.to_s

    raise "#{family}, #{side} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Identifier letter method returns combined representation") do
  test_cases = [
    [:C, :first, "C"],
    [:C, :second, "c"],
    [:S, :first, "S"],
    [:S, :second, "s"],
    [:X, :first, "X"],
    [:X, :second, "x"]
  ]

  test_cases.each do |family, side, expected_letter|
    identifier = Sashite::Sin::Identifier.new(family, side)
    result = identifier.letter

    raise "#{family}, #{side} letter should be #{expected_letter}, got #{result}" unless result == expected_letter
  end
end

run_test("Identifier side mutations return new instances") do
  identifier = Sashite::Sin::Identifier.new(:C, :first)

  # Test flip
  flipped = identifier.flip
  raise "flip should return new instance" if flipped.equal?(identifier)
  raise "flipped identifier should have opposite side" unless flipped.side == :second
  raise "flipped identifier should have same family" unless flipped.family == :C
  raise "flipped identifier should have lowercase letter" unless flipped.letter == "c"
  raise "original identifier should be unchanged" unless identifier.side == :first
end

run_test("Identifier attribute transformations") do
  identifier = Sashite::Sin::Identifier.new(:C, :first)

  # Test with_family
  s_identifier = identifier.with_family(:S)
  raise "with_family should return new instance" if s_identifier.equal?(identifier)
  raise "new identifier should have different family" unless s_identifier.family == :S
  raise "new identifier should have same side" unless s_identifier.side == identifier.side

  # Test with_side
  black_chess = identifier.with_side(:second)
  raise "with_side should return new instance" if black_chess.equal?(identifier)
  raise "new identifier should have different side" unless black_chess.side == :second
  raise "new identifier should have same family" unless black_chess.family == :C
  raise "new identifier should have lowercase letter" unless black_chess.letter == "c"
end

run_test("Identifier immutability") do
  identifier = Sashite::Sin::Identifier.new(:C, :first)

  # Test that identifier is frozen
  raise "identifier should be frozen" unless identifier.frozen?

  # Test that mutations don't affect original
  original_string = identifier.to_s
  flipped = identifier.flip

  raise "original identifier should be unchanged after flip" unless identifier.to_s == original_string
  raise "flipped identifier should be different" unless flipped.to_s == "c"
end

run_test("Identifier equality and hash") do
  identifier1 = Sashite::Sin::Identifier.new(:C, :first)
  identifier2 = Sashite::Sin::Identifier.new(:C, :first)
  identifier3 = Sashite::Sin::Identifier.new(:C, :second)
  identifier4 = Sashite::Sin::Identifier.new(:S, :first)

  # Test equality
  raise "identical identifiers should be equal" unless identifier1 == identifier2
  raise "different side should not be equal" if identifier1 == identifier3
  raise "different family should not be equal" if identifier1 == identifier4

  # Test hash consistency
  raise "equal identifiers should have same hash" unless identifier1.hash == identifier2.hash

  # Test in hash/set
  identifiers_set = Set.new([identifier1, identifier2, identifier3, identifier4])
  raise "set should contain 3 unique identifiers" unless identifiers_set.size == 3
end

run_test("Identifier family and side identification") do
  test_cases = [
    ["C", :C, :first, true, false],
    ["c", :C, :second, false, true],
    ["S", :S, :first, true, false],
    ["s", :S, :second, false, true]
  ]

  test_cases.each do |sin_string, expected_family, expected_side, is_first, is_second|
    identifier = Sashite::Sin.parse(sin_string)

    raise "#{sin_string}: wrong family" unless identifier.family == expected_family
    raise "#{sin_string}: wrong side" unless identifier.side == expected_side
    raise "#{sin_string}: wrong first_player?" unless identifier.first_player? == is_first
    raise "#{sin_string}: wrong second_player?" unless identifier.second_player? == is_second
  end
end

run_test("Identifier same_family? and same_side? methods") do
  c_first = Sashite::Sin::Identifier.new(:C, :first)
  c_second = Sashite::Sin::Identifier.new(:C, :second)
  s_first = Sashite::Sin::Identifier.new(:S, :first)
  s_second = Sashite::Sin::Identifier.new(:S, :second)

  # same_family? tests
  raise "C first and C second should be same family" unless c_first.same_family?(c_second)
  raise "C and S should not be same family" if c_first.same_family?(s_first)

  # same_side? tests
  raise "first player identifiers should be same side" unless c_first.same_side?(s_first)
  raise "different side identifiers should not be same side" if c_first.same_side?(c_second)
end

run_test("Identifier same_letter? alias for same_family?") do
  c_first = Sashite::Sin::Identifier.new(:C, :first)
  c_second = Sashite::Sin::Identifier.new(:C, :second)
  s_first = Sashite::Sin::Identifier.new(:S, :first)

  # same_letter? should work as alias for same_family?
  raise "same_letter? should work like same_family?" unless c_first.same_letter?(c_second)
  raise "same_letter? should work like same_family?" if c_first.same_letter?(s_first)

  # Should be identical results
  raise "same_letter? and same_family? should be identical" unless c_first.same_letter?(c_second) == c_first.same_family?(c_second)
end

run_test("Identifier transformation methods return self when appropriate") do
  identifier = Sashite::Sin::Identifier.new(:C, :first)

  # Test with_* methods that should return self
  raise "with_family with same family should return self" unless identifier.with_family(:C).equal?(identifier)
  raise "with_side with same side should return self" unless identifier.with_side(:first).equal?(identifier)
end

run_test("Identifier transformation chains") do
  identifier = Sashite::Sin::Identifier.new(:C, :first)

  # Test flip then flip
  flipped = identifier.flip
  back_to_original = flipped.flip
  raise "flip then flip should equal original" unless back_to_original == identifier

  # Test complex chain
  transformed = identifier.flip.with_family(:S).flip
  raise "complex chain should work" unless transformed.to_s == "S"
  raise "original should be unchanged" unless identifier.to_s == "C"
end

run_test("Identifier error handling for invalid families") do
  # Invalid families
  invalid_families = [nil, "", "C", "chess", "CHESS", 1, [], :AA, :Aa, :"", :"1", :"1A", :a, :c]

  invalid_families.each do |family|
    begin
      Sashite::Sin::Identifier.new(family, :first)
      raise "Should have raised error for invalid family #{family.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid family" unless e.message.include?("Family must be")
    end
  end

  # Invalid sides
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Sin::Identifier.new(:C, side)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end
end

run_test("Identifier error handling for invalid SIN strings") do
  # Invalid SIN strings
  invalid_sins = ["", "Chess", "AA", "123", nil, Object]

  invalid_sins.each do |sin|
    begin
      Sashite::Sin.parse(sin)
      raise "Should have raised error for #{sin.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid SIN" unless e.message.include?("Invalid SIN")
    end
  end
end

# Test family examples with new API
run_test("Family identifiers with new API") do
  # Chess family (C)
  chess_first = Sashite::Sin.identifier(:C, :first)
  raise "Chess first should be first player" unless chess_first.first_player?
  raise "Chess family should be :C" unless chess_first.family == :C

  chess_second = Sashite::Sin.identifier(:C, :second)
  raise "Chess second should be second player" unless chess_second.second_player?
  raise "Chess family should be :C" unless chess_second.family == :C

  # Shogi family (S)
  shogi_first = Sashite::Sin.identifier(:S, :first)
  raise "Shogi family should be :S" unless shogi_first.family == :S
  raise "Shogi SIN should be S" unless shogi_first.to_s == "S"

  # Xiangqi family (X)
  xiangqi_first = Sashite::Sin.identifier(:X, :first)
  raise "Xiangqi family should be :X" unless xiangqi_first.family == :X
  raise "Xiangqi SIN should be X" unless xiangqi_first.to_s == "X"
end

run_test("Cross-style transformations with new API") do
  # Test that identifiers can be transformed across different families
  identifier = Sashite::Sin.identifier(:C, :first)

  # Chain transformations
  transformed = identifier.flip.with_family(:S).flip.with_family(:X)
  expected_final = "X"  # Should end up as first player X

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original identifier should be unchanged" unless identifier.to_s == "C"
end

# Test practical usage scenarios with new API
run_test("Practical usage - identifier collections with new API") do
  identifiers = [
    Sashite::Sin.identifier(:C, :first),
    Sashite::Sin.identifier(:S, :first),
    Sashite::Sin.identifier(:X, :first),
    Sashite::Sin.identifier(:C, :second)
  ]

  # Filter by side
  first_player_identifiers = identifiers.select(&:first_player?)
  raise "Should have 3 first player identifiers" unless first_player_identifiers.size == 3

  # Group by family
  by_family = identifiers.group_by(&:family)
  raise "Should have C family grouped" unless by_family[:C].size == 2

  # Find specific families
  c_identifiers = identifiers.select { |i| i.same_family?(identifiers.first) }
  raise "Should have 2 C family identifiers" unless c_identifiers.size == 2
end

run_test("Practical usage - game configuration with new API") do
  # Simulate multi-style match setup
  white_identifier = Sashite::Sin.identifier(:C, :first)
  black_identifier = Sashite::Sin.identifier(:S, :second)

  raise "White should be first player" unless white_identifier.first_player?
  raise "Black should be second player" unless black_identifier.second_player?
  raise "Identifiers should have different families" unless !white_identifier.same_family?(black_identifier)
  raise "Identifiers should have different sides" unless !white_identifier.same_side?(black_identifier)

  # Test identifier switching
  switched = white_identifier.with_family(:S)
  raise "Switched identifier should have S family" unless switched.family == :S
  raise "Switched identifier should keep white's side" unless switched.side == white_identifier.side
end

# Test all 26 letters
run_test("All 26 ASCII letters work correctly") do
  letters = ("A".."Z").to_a + ("a".."z").to_a

  letters.each do |letter|
    # Test parsing
    identifier = Sashite::Sin.parse(letter)
    expected_family = letter.upcase.to_sym
    raise "#{letter} should have correct family" unless identifier.family == expected_family

    # Test side inference
    expected_side = letter == letter.upcase ? :first : :second
    raise "#{letter} should have correct side" unless identifier.side == expected_side

    # Test roundtrip
    raise "#{letter} should roundtrip correctly" unless identifier.to_s == letter
    raise "#{letter} should have correct letter representation" unless identifier.letter == letter
  end
end

run_test("Family case transformations work correctly") do
  # Test all uppercase letters can flip to lowercase
  ("A".."Z").each do |upper|
    identifier = Sashite::Sin.parse(upper)
    flipped = identifier.flip
    expected_lower = upper.downcase

    raise "#{upper} should flip to #{expected_lower}" unless flipped.to_s == expected_lower
    raise "#{upper} flipped should be second player" unless flipped.second_player?
    raise "#{upper} flipped should have same family" unless flipped.family == identifier.family
  end

  # Test all lowercase letters can flip to uppercase
  ("a".."z").each do |lower|
    identifier = Sashite::Sin.parse(lower)
    flipped = identifier.flip
    expected_upper = lower.upcase

    raise "#{lower} should flip to #{expected_upper}" unless flipped.to_s == expected_upper
    raise "#{lower} flipped should be first player" unless flipped.first_player?
    raise "#{lower} flipped should have same family" unless flipped.family == identifier.family
  end
end

run_test("Same family detection works correctly") do
  test_pairs = [
    ["A", "a"], ["B", "b"], ["C", "c"], ["X", "x"], ["Y", "y"], ["Z", "z"]
  ]

  test_pairs.each do |upper, lower|
    identifier1 = Sashite::Sin.parse(upper)
    identifier2 = Sashite::Sin.parse(lower)

    raise "#{upper} and #{lower} should be same family" unless identifier1.same_family?(identifier2)
    raise "#{upper} and #{lower} should not be same side" if identifier1.same_side?(identifier2)
  end
end

# Test regex compliance
run_test("Regex pattern compliance with spec") do
  # Test against the specification regex: \A[A-Za-z]\z
  spec_regex = /\A[A-Za-z]\z/

  test_strings = [
    "A", "B", "C", "X", "Y", "Z", "a", "b", "c", "x", "y", "z",
    "", "AA", "Chess", "123", "1A", "A1", "CHESS", "chess"
  ]

  test_strings.each do |string|
    spec_match = string.match?(spec_regex)
    sin_valid = Sashite::Sin.valid?(string)

    raise "#{string.inspect}: spec regex and SIN validation disagree" unless spec_match == sin_valid
  end
end

# Test constants
run_test("Regular expression constant is correctly defined") do
  regex = Sashite::Sin::Identifier::SIN_PATTERN

  raise "SIN_PATTERN should match valid SINs" unless "C".match?(regex)
  raise "SIN_PATTERN should match lowercase SINs" unless "c".match?(regex)
  raise "SIN_PATTERN should not match multi-char" if "CC".match?(regex)
  raise "SIN_PATTERN should not match numbers" if "1".match?(regex)
end

# Test performance with new API
run_test("Performance - repeated operations with new API") do
  # Test performance with many repeated calls
  1000.times do
    identifier = Sashite::Sin.identifier(:C, :first)
    flipped = identifier.flip
    renamed = identifier.with_family(:S)

    raise "Performance test failed" unless Sashite::Sin.valid?("C")
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless renamed.family == :S
  end
end

# Test constants and validation
run_test("Identifier class constants are properly defined") do
  identifier_class = Sashite::Sin::Identifier

  # Test side constants
  raise "FIRST_PLAYER should be :first" unless identifier_class::FIRST_PLAYER == :first
  raise "SECOND_PLAYER should be :second" unless identifier_class::SECOND_PLAYER == :second

  # Test valid sides
  raise "VALID_SIDES should contain correct values" unless identifier_class::VALID_SIDES == [:first, :second]

  # Test valid families
  raise "VALID_FAMILIES should contain :A to :Z" unless identifier_class::VALID_FAMILIES == (:A..:Z).to_a
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    [:C, :first],
    [:S, :second],
    [:X, :first],
    [:M, :second]
  ]

  test_cases.each do |family, side|
    # Create identifier -> to_s -> parse -> compare
    original = Sashite::Sin::Identifier.new(family, side)
    sin_string = original.to_s
    parsed = Sashite::Sin.parse(sin_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different family" unless original.family == parsed.family
    raise "Roundtrip failed: different side" unless original.side == parsed.side
  end
end

# Test case sensitivity requirements
run_test("Case sensitivity maintained correctly") do
  # Test that we don't accept mixed or improper case
  valid_cases = ["A", "B", "C", "a", "b", "c"]
  invalid_cases = ["Aa", "aA", "Ab", "bA"]

  valid_cases.each do |sin|
    raise "#{sin} should be valid" unless Sashite::Sin.valid?(sin)
  end

  invalid_cases.each do |sin|
    raise "#{sin} should be invalid" if Sashite::Sin.valid?(sin)
  end
end

# Test family validation
run_test("Family validation works correctly") do
  # Valid families should be :A to :Z only
  valid_families = (:"A"..:"Z").to_a
  invalid_families = [:a, :c, :z, :AA, :Chess, :"", :"1", nil]

  valid_families.each do |family|
    # Should not raise error
    identifier = Sashite::Sin::Identifier.new(family, :first)
    raise "Valid family #{family} should work" unless identifier.family == family
  end

  invalid_families.each do |family|
    begin
      Sashite::Sin::Identifier.new(family, :first)
      raise "Should have raised error for invalid family #{family.inspect}"
    rescue ArgumentError
      # Expected
    end
  end
end

# Test that letter representation is always consistent with family and side
run_test("Letter representation consistency") do
  test_cases = [
    [:A, :first, "A"],
    [:A, :second, "a"],
    [:C, :first, "C"],
    [:C, :second, "c"],
    [:S, :first, "S"],
    [:S, :second, "s"],
    [:Z, :first, "Z"],
    [:Z, :second, "z"]
  ]

  test_cases.each do |family, side, expected_letter|
    identifier = Sashite::Sin::Identifier.new(family, side)

    raise "Letter should match expected" unless identifier.letter == expected_letter
    raise "to_s should match letter" unless identifier.to_s == identifier.letter
    raise "Letter case should match side" unless (identifier.letter == identifier.letter.upcase) == identifier.first_player?
  end
end

puts
puts "All SIN v1.0.0 tests passed!"
puts
