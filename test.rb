# frozen_string_literal: true

# Tests for Sashite::Snn (Style Name Notation)
#
# Tests the SNN implementation for Ruby, focusing on the modern object-oriented API
# with the Style class using letter-based attributes conforming to SNN v1.0.0 specification.

require_relative "lib/sashite-snn"
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
puts "Tests for Sashite::Snn (Style Name Notation) v1.0.0"
puts

# Test basic validation (module level)
run_test("Module SNN validation accepts valid notations") do
  valid_snns = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
  ]

  valid_snns.each do |snn|
    raise "#{snn.inspect} should be valid" unless Sashite::Snn.valid?(snn)
  end
end

run_test("Module SNN validation rejects invalid notations") do
  invalid_snns = [
    "", "AA", "Aa", "aA", "aa", "AB", "ab", "Chess", "CHESS", "chess",
    "123", "1", "2", "A1", "1A", "A2", "2A", "B1", "1B",
    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    " A", "A ", "A B", "A-B", "A_B", " ", "\t", "\n",
    "α", "β", "♕", "♔", "🀄", "象", "將", "CHESS", "SHOGI"
  ]

  invalid_snns.each do |snn|
    raise "#{snn.inspect} should be invalid" if Sashite::Snn.valid?(snn)
  end
end

run_test("Module SNN validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Snn.valid?(input)
  end
end

# Test module parse method delegates to Style
run_test("Module parse delegates to Style class") do
  snn_string = "C"
  style = Sashite::Snn.parse(snn_string)

  raise "parse should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "style should have correct SNN string" unless style.to_s == snn_string
end

# Test module style factory method
run_test("Module style factory method creates correct instances") do
  style = Sashite::Snn.style(:C, :first)

  raise "style factory should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "style should have correct letter" unless style.letter == :C
  raise "style should have correct side" unless style.side == :first
  raise "style should have correct SNN string" unless style.to_s == "C"
end

# Test the Style class with letter-based API
run_test("Style.parse creates correct instances with letter attributes") do
  test_cases = {
    "C" => { letter: :C, side: :first },
    "c" => { letter: :c, side: :second },
    "S" => { letter: :S, side: :first },
    "s" => { letter: :s, side: :second },
    "X" => { letter: :X, side: :first },
    "x" => { letter: :x, side: :second }
  }

  test_cases.each do |snn_string, expected|
    style = Sashite::Snn.parse(snn_string)

    raise "#{snn_string}: wrong letter" unless style.letter == expected[:letter]
    raise "#{snn_string}: wrong side" unless style.side == expected[:side]
  end
end

run_test("Style constructor with letter parameters") do
  test_cases = [
    [:C, :first, "C"],
    [:c, :second, "c"],
    [:S, :first, "S"],
    [:s, :second, "s"],
    [:X, :first, "X"],
    [:x, :second, "x"]
  ]

  test_cases.each do |letter, side, expected_snn|
    style = Sashite::Snn::Style.new(letter, side)

    raise "letter should be #{letter}" unless style.letter == letter
    raise "side should be #{side}" unless style.side == side
    raise "SNN string should be #{expected_snn}" unless style.to_s == expected_snn
  end
end

run_test("Style to_s returns correct SNN string") do
  test_cases = [
    [:C, :first, "C"],
    [:c, :second, "c"],
    [:S, :first, "S"],
    [:s, :second, "s"],
    [:X, :first, "X"],
    [:x, :second, "x"]
  ]

  test_cases.each do |letter, side, expected|
    style = Sashite::Snn::Style.new(letter, side)
    result = style.to_s

    raise "#{letter}, #{side} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Style side mutations return new instances") do
  style = Sashite::Snn::Style.new(:C, :first)

  # Test flip
  flipped = style.flip
  raise "flip should return new instance" if flipped.equal?(style)
  raise "flipped style should have opposite side" unless flipped.side == :second
  raise "flipped style should have lowercase letter" unless flipped.letter == :c
  raise "original style should be unchanged" unless style.side == :first
end

run_test("Style attribute transformations") do
  style = Sashite::Snn::Style.new(:C, :first)

  # Test with_letter
  s_style = style.with_letter(:S)
  raise "with_letter should return new instance" if s_style.equal?(style)
  raise "new style should have different letter" unless s_style.letter == :S
  raise "new style should have same side" unless s_style.side == style.side

  # Test with_side
  black_chess = style.with_side(:second)
  raise "with_side should return new instance" if black_chess.equal?(style)
  raise "new style should have different side" unless black_chess.side == :second
  raise "new style should have lowercase letter" unless black_chess.letter == :c
end

run_test("Style immutability") do
  style = Sashite::Snn::Style.new(:C, :first)

  # Test that style is frozen
  raise "style should be frozen" unless style.frozen?

  # Test that mutations don't affect original
  original_string = style.to_s
  flipped = style.flip

  raise "original style should be unchanged after flip" unless style.to_s == original_string
  raise "flipped style should be different" unless flipped.to_s == "c"
end

run_test("Style equality and hash") do
  style1 = Sashite::Snn::Style.new(:C, :first)
  style2 = Sashite::Snn::Style.new(:C, :first)
  style3 = Sashite::Snn::Style.new(:c, :second)
  style4 = Sashite::Snn::Style.new(:S, :first)

  # Test equality
  raise "identical styles should be equal" unless style1 == style2
  raise "different side should not be equal" if style1 == style3
  raise "different letter should not be equal" if style1 == style4

  # Test hash consistency
  raise "equal styles should have same hash" unless style1.hash == style2.hash

  # Test in hash/set
  styles_set = Set.new([style1, style2, style3, style4])
  raise "set should contain 3 unique styles" unless styles_set.size == 3
end

run_test("Style letter and side identification") do
  test_cases = [
    ["C", :C, :first, true, false],
    ["c", :c, :second, false, true],
    ["S", :S, :first, true, false],
    ["s", :s, :second, false, true]
  ]

  test_cases.each do |snn_string, expected_letter, expected_side, is_first, is_second|
    style = Sashite::Snn.parse(snn_string)

    raise "#{snn_string}: wrong letter" unless style.letter == expected_letter
    raise "#{snn_string}: wrong side" unless style.side == expected_side
    raise "#{snn_string}: wrong first_player?" unless style.first_player? == is_first
    raise "#{snn_string}: wrong second_player?" unless style.second_player? == is_second
  end
end

run_test("Style same_letter? and same_side? methods") do
  c_first = Sashite::Snn::Style.new(:C, :first)
  c_second = Sashite::Snn::Style.new(:c, :second)
  s_first = Sashite::Snn::Style.new(:S, :first)
  s_second = Sashite::Snn::Style.new(:s, :second)

  # same_letter? tests (case-insensitive)
  raise "C and c should be same letter family" unless c_first.same_letter?(c_second)
  raise "C and S should not be same letter family" if c_first.same_letter?(s_first)

  # same_side? tests
  raise "first player styles should be same side" unless c_first.same_side?(s_first)
  raise "different side styles should not be same side" if c_first.same_side?(c_second)
end

run_test("Style transformation methods return self when appropriate") do
  style = Sashite::Snn::Style.new(:C, :first)

  # Test with_* methods that should return self
  raise "with_letter with same letter should return self" unless style.with_letter(:C).equal?(style)
  raise "with_side with same side should return self" unless style.with_side(:first).equal?(style)
end

run_test("Style transformation chains") do
  style = Sashite::Snn::Style.new(:C, :first)

  # Test flip then flip
  flipped = style.flip
  back_to_original = flipped.flip
  raise "flip then flip should equal original" unless back_to_original == style

  # Test complex chain
  transformed = style.flip.with_letter(:S).flip
  raise "complex chain should work" unless transformed.to_s == "S"
  raise "original should be unchanged" unless style.to_s == "C"
end

run_test("Style error handling for invalid letters") do
  # Invalid letters
  invalid_letters = [nil, "", "C", "chess", "CHESS", 1, [], :AA, :Aa, :"", :"1", :"1A"]

  invalid_letters.each do |letter|
    begin
      Sashite::Snn::Style.new(letter, :first)
      raise "Should have raised error for invalid letter #{letter.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid letter" unless e.message.include?("Letter must be")
    end
  end

  # Invalid sides
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Snn::Style.new(:C, side)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end
end

run_test("Style error handling for invalid SNN strings") do
  # Invalid SNN strings
  invalid_snns = ["", "Chess", "AA", "123", nil, Object]

  invalid_snns.each do |snn|
    begin
      Sashite::Snn.parse(snn)
      raise "Should have raised error for #{snn.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid SNN" unless e.message.include?("Invalid SNN")
    end
  end
end

# Test letter family examples with new API
run_test("Letter family styles with new API") do
  # Chess family (C)
  chess_first = Sashite::Snn.style(:C, :first)
  raise "Chess first should be first player" unless chess_first.first_player?
  raise "Chess letter should be :C" unless chess_first.letter == :C

  chess_second = Sashite::Snn.style(:c, :second)
  raise "Chess second should be second player" unless chess_second.second_player?
  raise "Chess letter should be :c" unless chess_second.letter == :c

  # Shogi family (S)
  shogi_first = Sashite::Snn.style(:S, :first)
  raise "Shogi letter should be :S" unless shogi_first.letter == :S
  raise "Shogi SNN should be S" unless shogi_first.to_s == "S"

  # Xiangqi family (X)
  xiangqi_first = Sashite::Snn.style(:X, :first)
  raise "Xiangqi letter should be :X" unless xiangqi_first.letter == :X
  raise "Xiangqi SNN should be X" unless xiangqi_first.to_s == "X"
end

run_test("Cross-style transformations with new API") do
  # Test that styles can be transformed across different letter families
  style = Sashite::Snn.style(:C, :first)

  # Chain transformations
  transformed = style.flip.with_letter(:S).flip.with_letter(:X)
  expected_final = "X"  # Should end up as first player X

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original style should be unchanged" unless style.to_s == "C"
end

# Test practical usage scenarios with new API
run_test("Practical usage - style collections with new API") do
  styles = [
    Sashite::Snn.style(:C, :first),
    Sashite::Snn.style(:S, :first),
    Sashite::Snn.style(:X, :first),
    Sashite::Snn.style(:c, :second)
  ]

  # Filter by side
  first_player_styles = styles.select(&:first_player?)
  raise "Should have 3 first player styles" unless first_player_styles.size == 3

  # Group by letter family
  by_letter_family = styles.group_by { |s| s.letter.to_s.upcase }
  raise "Should have C letter family grouped" unless by_letter_family["C"].size == 2

  # Find specific letter families
  c_styles = styles.select { |s| s.same_letter?(styles.first) }
  raise "Should have 2 C family styles" unless c_styles.size == 2
end

run_test("Practical usage - game configuration with new API") do
  # Simulate multi-style match setup
  white_style = Sashite::Snn.style(:C, :first)
  black_style = Sashite::Snn.style(:s, :second)

  raise "White should be first player" unless white_style.first_player?
  raise "Black should be second player" unless black_style.second_player?
  raise "Styles should have different letter families" unless !white_style.same_letter?(black_style)
  raise "Styles should have different sides" unless !white_style.same_side?(black_style)

  # Test style switching
  switched = white_style.with_letter(:S)
  raise "Switched style should have S letter" unless switched.letter == :S
  raise "Switched style should keep white's side" unless switched.side == white_style.side
end

# Test all 26 letters
run_test("All 26 ASCII letters work correctly") do
  letters = ("A".."Z").to_a + ("a".."z").to_a

  letters.each do |letter|
    # Test parsing
    style = Sashite::Snn.parse(letter)
    raise "#{letter} should parse correctly" unless style.letter.to_s == letter

    # Test side inference
    expected_side = letter == letter.upcase ? :first : :second
    raise "#{letter} should have correct side" unless style.side == expected_side

    # Test roundtrip
    raise "#{letter} should roundtrip correctly" unless style.to_s == letter
  end
end

run_test("Letter case transformations work correctly") do
  # Test all uppercase letters can flip to lowercase
  ("A".."Z").each do |upper|
    style = Sashite::Snn.parse(upper)
    flipped = style.flip
    expected_lower = upper.downcase

    raise "#{upper} should flip to #{expected_lower}" unless flipped.to_s == expected_lower
    raise "#{upper} flipped should be second player" unless flipped.second_player?
  end

  # Test all lowercase letters can flip to uppercase
  ("a".."z").each do |lower|
    style = Sashite::Snn.parse(lower)
    flipped = style.flip
    expected_upper = lower.upcase

    raise "#{lower} should flip to #{expected_upper}" unless flipped.to_s == expected_upper
    raise "#{lower} flipped should be first player" unless flipped.first_player?
  end
end

run_test("Same letter family detection works correctly") do
  test_pairs = [
    ["A", "a"], ["B", "b"], ["C", "c"], ["X", "x"], ["Y", "y"], ["Z", "z"]
  ]

  test_pairs.each do |upper, lower|
    style1 = Sashite::Snn.parse(upper)
    style2 = Sashite::Snn.parse(lower)

    raise "#{upper} and #{lower} should be same letter family" unless style1.same_letter?(style2)
    raise "#{upper} and #{lower} should not be same side" if style1.same_side?(style2)
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
    snn_valid = Sashite::Snn.valid?(string)

    raise "#{string.inspect}: spec regex and SNN validation disagree" unless spec_match == snn_valid
  end
end

# Test constants
run_test("Regular expression constant is correctly defined") do
  regex = Sashite::Snn::Style::SNN_PATTERN

  raise "SNN_PATTERN should match valid SNNs" unless "C".match?(regex)
  raise "SNN_PATTERN should match lowercase SNNs" unless "c".match?(regex)
  raise "SNN_PATTERN should not match multi-char" if "CC".match?(regex)
  raise "SNN_PATTERN should not match numbers" if "1".match?(regex)
end

# Test performance with new API
run_test("Performance - repeated operations with new API") do
  # Test performance with many repeated calls
  1000.times do
    style = Sashite::Snn.style(:C, :first)
    flipped = style.flip
    renamed = style.with_letter(:S)

    raise "Performance test failed" unless Sashite::Snn.valid?("C")
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless renamed.letter == :S
  end
end

# Test constants and validation
run_test("Style class constants are properly defined") do
  style_class = Sashite::Snn::Style

  # Test side constants
  raise "FIRST_PLAYER should be :first" unless style_class::FIRST_PLAYER == :first
  raise "SECOND_PLAYER should be :second" unless style_class::SECOND_PLAYER == :second

  # Test valid sides
  raise "VALID_SIDES should contain correct values" unless style_class::VALID_SIDES == [:first, :second]
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    [:C, :first],
    [:s, :second],
    [:X, :first],
    [:m, :second]
  ]

  test_cases.each do |letter, side|
    # Create style -> to_s -> parse -> compare
    original = Sashite::Snn::Style.new(letter, side)
    snn_string = original.to_s
    parsed = Sashite::Snn.parse(snn_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different letter" unless original.letter == parsed.letter
    raise "Roundtrip failed: different side" unless original.side == parsed.side
  end
end

# Test case sensitivity requirements
run_test("Case sensitivity maintained correctly") do
  # Test that we don't accept mixed or improper case
  valid_cases = ["A", "B", "C", "a", "b", "c"]
  invalid_cases = ["Aa", "aA", "Ab", "bA"]

  valid_cases.each do |snn|
    raise "#{snn} should be valid" unless Sashite::Snn.valid?(snn)
  end

  invalid_cases.each do |snn|
    raise "#{snn} should be invalid" if Sashite::Snn.valid?(snn)
  end
end

puts
puts "All SNN v1.0.0 tests passed!"
puts
