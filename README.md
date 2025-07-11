# Sin.rb

[![Version](https://img.shields.io/github/v/tag/sashite/sin.rb?label=Version&logo=github)](https://github.com/sashite/sin.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/sin.rb/main)
![Ruby](https://github.com/sashite/sin.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/sin.rb?label=License&logo=github)](https://github.com/sashite/sin.rb/raw/main/LICENSE.md)

> **SIN** (Style Identifier Notation) implementation for the Ruby language.

## What is SIN?

SIN (Style Identifier Notation) provides a compact, ASCII-based format for identifying **styles** in abstract strategy board games. SIN uses single-character identifiers with case encoding to represent both style identity and player assignment simultaneously.

This gem implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/), providing a rule-agnostic notation system for style identification in board games.

## Installation

```ruby
# In your Gemfile
gem "sashite-sin"
```

Or install manually:

```sh
gem install sashite-sin
```

## Usage

### Basic Operations

```ruby
require "sashite/sin"

# Parse SIN strings into identifier objects
identifier = Sashite::Sin.parse("C")           # => #<Sin::Identifier letter=:C side=:first>
identifier.to_s                                # => "C"
identifier.letter                              # => :C
identifier.side                                # => :first

# Create identifiers directly
identifier = Sashite::Sin.identifier(:C, :first)           # => #<Sin::Identifier letter=:C side=:first>
identifier = Sashite::Sin::Identifier.new(:c, :second)     # => #<Sin::Identifier letter=:c side=:second>

# Validate SIN strings
Sashite::Sin.valid?("C")                 # => true
Sashite::Sin.valid?("c")                 # => true
Sashite::Sin.valid?("1")                 # => false (not a letter)
Sashite::Sin.valid?("CC")                # => false (not single character)
```

### Identifier Transformations

```ruby
# All transformations return new immutable instances
identifier = Sashite::Sin.parse("C")

# Flip player assignment
flipped = identifier.flip # => #<Sin::Identifier letter=:c side=:second>
flipped.to_s # => "c"

# Change letter
changed = identifier.with_letter(:S) # => #<Sin::Identifier letter=:S side=:first>
changed.to_s # => "S"

# Change side
other_side = identifier.with_side(:second) # => #<Sin::Identifier letter=:c side=:second>
other_side.to_s # => "c"

# Chain transformations
result = identifier.flip.with_letter(:M) # => #<Sin::Identifier letter=:m side=:second>
result.to_s # => "m"
```

### Player and Style Queries

```ruby
identifier = Sashite::Sin.parse("C")
opposite = Sashite::Sin.parse("s")

# Player identification
identifier.first_player?                       # => true
identifier.second_player?                      # => false
opposite.first_player?                    # => false
opposite.second_player?                   # => true

# Letter comparison
chess1 = Sashite::Sin.parse("C")
chess2 = Sashite::Sin.parse("c")
shogi = Sashite::Sin.parse("S")

chess1.same_letter?(chess2)               # => true (both use letter C)
chess1.same_side?(shogi)                  # => true (both first player)
chess1.same_letter?(shogi)                # => false (different letters)
```

### Identifier Collections

```ruby
# Working with multiple identifiers
identifiers = %w[C c S s M m].map { |sin| Sashite::Sin.parse(sin) }

# Filter by player
first_player_identifiers = identifiers.select(&:first_player?)
first_player_identifiers.map(&:to_s) # => ["C", "S", "M"]

# Group by letter family
by_letter = identifiers.group_by { |i| i.letter.to_s.upcase }
by_letter["C"].size # => 2 (both C and c)

# Find specific combinations
chess_identifiers = identifiers.select { |i| i.letter.to_s.upcase == "C" }
chess_identifiers.map(&:to_s) # => ["C", "c"]
```

## Format Specification

### Structure
```
<style-letter>
```

### Grammar (BNF)
```bnf
<sin> ::= <uppercase-letter> | <lowercase-letter>

<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
```

### Regular Expression
```ruby
/\A[A-Za-z]\z/
```

### Style Attribute Mapping

| Style Attribute | SIN Encoding | Examples |
|-----------------|--------------|----------|
| **Style Family** | Letter choice | `C`/`c` = Chess family |
| **Player Assignment** | Letter case | `C` = First player, `c` = Second player |

## Game Examples

The SIN specification is rule-agnostic and does not define specific letter assignments. However, here are common usage patterns:

### Traditional Game Families

```ruby
# Chess family identifiers
chess_white = Sashite::Sin.parse("C")    # First player, Chess family
chess_black = Sashite::Sin.parse("c")    # Second player, Chess family

# Shōgi family identifiers
shogi_sente = Sashite::Sin.parse("S")    # First player, Shōgi family
shogi_gote = Sashite::Sin.parse("s")     # Second player, Shōgi family

# Xiangqi family identifiers
xiangqi_red = Sashite::Sin.parse("X")    # First player, Xiangqi family
xiangqi_black = Sashite::Sin.parse("x")  # Second player, Xiangqi family
```

### Cross-Style Scenarios

```ruby
# Different families in one match
def create_hybrid_match
  [
    Sashite::Sin.parse("C"),             # First player uses Chess family
    Sashite::Sin.parse("s")              # Second player uses Shōgi family
  ]
end

identifiers = create_hybrid_match
identifiers[0].same_side?(identifiers[1])         # => false (different players)
identifiers[0].same_letter?(identifiers[1])       # => false (different families)
```

### Variant Families

```ruby
# Different letters can represent variants within traditions
makruk = Sashite::Sin.parse("M")        # Makruk (Thai Chess) family
janggi = Sashite::Sin.parse("J")        # Janggi (Korean Chess) family
ogi = Sashite::Sin.parse("O")           # Ōgi (王棋) family

# Each family can have both players
makruk_black = makruk.flip              # Second player Makruk
makruk_black.to_s                       # => "m"
```

## API Reference

### Main Module Methods

- `Sashite::Sin.valid?(sin_string)` - Check if string is valid SIN notation
- `Sashite::Sin.parse(sin_string)` - Parse SIN string into Identifier object
- `Sashite::Sin.identifier(letter, side)` - Create identifier instance directly

### Identifier Class

#### Creation and Parsing
- `Sashite::Sin::Identifier.new(letter, side)` - Create identifier instance
- `Sashite::Sin::Identifier.parse(sin_string)` - Parse SIN string

#### Attribute Access
- `#letter` - Get style letter (symbol :A through :z)
- `#side` - Get player side (:first or :second)
- `#to_s` - Convert to SIN string representation

#### Player Queries
- `#first_player?` - Check if first player identifier
- `#second_player?` - Check if second player identifier

#### Transformations (immutable - return new instances)
- `#flip` - Switch player assignment
- `#with_letter(new_letter)` - Create identifier with different letter
- `#with_side(new_side)` - Create identifier with different side

#### Comparison Methods
- `#same_letter?(other)` - Check if same style letter (case-insensitive)
- `#same_side?(other)` - Check if same player side
- `#==(other)` - Full equality comparison

### Identifier Class Constants

- `Sashite::Sin::Identifier::FIRST_PLAYER` - Symbol for first player (:first)
- `Sashite::Sin::Identifier::SECOND_PLAYER` - Symbol for second player (:second)
- `Sashite::Sin::Identifier::VALID_SIDES` - Array of valid sides
- `Sashite::Sin::Identifier::SIN_PATTERN` - Regular expression for SIN validation

## Advanced Usage

### Letter Case and Side Mapping

```ruby
# SIN encodes player assignment through case
upper_case_letters = ("A".."Z").map { |letter| Sashite::Sin.parse(letter) }
lower_case_letters = ("a".."z").map { |letter| Sashite::Sin.parse(letter) }

# All uppercase letters are first player
upper_case_letters.all?(&:first_player?) # => true

# All lowercase letters are second player
lower_case_letters.all?(&:second_player?) # => true

# Letter families are related by case
letter_a_first = Sashite::Sin.parse("A")
letter_a_second = Sashite::Sin.parse("a")

letter_a_first.same_letter?(letter_a_second)  # => true
letter_a_first.same_side?(letter_a_second)    # => false
```

### Immutable Transformations

```ruby
# All transformations return new instances
original = Sashite::Sin.identifier(:C, :first)
flipped = original.flip
changed_letter = original.with_letter(:S)

# Original identifier is never modified
original.to_s                           # => "C" (unchanged)
flipped.to_s                            # => "c"
changed_letter.to_s                     # => "S"

# Transformations can be chained
result = original.flip.with_letter(:M).flip
result.to_s # => "M"
```

## Protocol Mapping

Following the [Sashité Protocol](https://sashite.dev/protocol/):

| Protocol Attribute | SIN Encoding | Examples | Notes |
|-------------------|--------------|----------|-------|
| **Style Family** | Letter choice | `C`, `S`, `X` | Rule-agnostic letter assignment |
| **Player Assignment** | Case encoding | `C` = First player, `c` = Second player | Case determines side |

## System Constraints

- **26 possible identifiers** per player using ASCII letters (A-Z, a-z)
- **Exactly 2 players** through case distinction
- **Single character** per style-player combination
- **Rule-agnostic** - no predefined letter meanings

## Design Properties

- **ASCII compatibility**: Maximum portability across systems
- **Rule-agnostic**: Independent of specific game mechanics
- **Minimal overhead**: Single character per style-player combination
- **Canonical representation**: Each style-player combination has exactly one SIN identifier
- **Immutable**: All identifier instances are frozen and transformations return new objects
- **Functional**: Pure functions with no side effects

## Related Specifications

- [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) - Complete technical specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) - Practical implementation examples
- [Sashité Protocol](https://sashite.dev/protocol/) - Conceptual foundation for abstract strategy board games
- [PIN](https://sashite.dev/specs/pin/) - Piece Identifier Notation
- [PNN](https://sashite.dev/specs/pnn/) - Piece Name Notation (style-aware piece representation)
- [QPI](https://sashite.dev/specs/qpi/) - Qualified Piece Identifier

## Documentation

- [Official SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/)
- [SIN Examples Documentation](https://sashite.dev/specs/sin/1.0.0/examples/)
- [Sashité Protocol Foundation](https://sashite.dev/protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/sin.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/sin.rb.git
cd sin.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
