# Sin.rb

[![Version](https://img.shields.io/github/v/tag/sashite/sin.rb?label=Version&logo=github)](https://github.com/sashite/sin.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/sin.rb/main)
![Ruby](https://github.com/sashite/sin.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/sin.rb?label=License&logo=github)](https://github.com/sashite/sin.rb/raw/main/LICENSE.md)

> **SIN** (Style Identifier Notation) implementation for the Ruby language.

## What is SIN?

SIN (Style Identifier Notation) provides a compact, ASCII-based format for identifying **styles** in abstract strategy board games. SIN uses single-character identifiers with case encoding to represent both style identity and player assignment simultaneously.

This gem implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) exactly, providing a rule-agnostic notation system for style identification in board games.

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
identifier = Sashite::Sin.parse("C")           # Family=:C, Side=:first
identifier.to_s                                # => "C"
identifier.family                              # => :C
identifier.side                                # => :first
identifier.letter                              # => "C" (combined representation)

# Create identifiers directly
identifier = Sashite::Sin.identifier(:C, :first)           # Family=:C, Side=:first
identifier = Sashite::Sin::Identifier.new(:C, :second)     # Family=:C, Side=:second

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
flipped = identifier.flip # Family=:C, Side=:second
flipped.to_s # => "c"

# Change family
changed = identifier.with_family(:S) # Family=:S, Side=:first
changed.to_s # => "S"

# Change side
other_side = identifier.with_side(:second) # Family=:C, Side=:second
other_side.to_s # => "c"

# Chain transformations
result = identifier.flip.with_family(:M) # Family=:M, Side=:second
result.to_s # => "m"
```

### Player and Style Queries

```ruby
identifier = Sashite::Sin.parse("C")
opposite = Sashite::Sin.parse("s")

# Player identification
identifier.first_player?                       # => true
identifier.second_player?                      # => false
opposite.first_player?                         # => false
opposite.second_player?                        # => true

# Family and side comparison
chess1 = Sashite::Sin.parse("C")
chess2 = Sashite::Sin.parse("c")
shogi = Sashite::Sin.parse("S")

chess1.same_family?(chess2)               # => true (both Chess family)
chess1.same_side?(shogi)                  # => true (both first player)
chess1.same_family?(shogi)                # => false (different families)
```

### Identifier Collections

```ruby
# Working with multiple identifiers
identifiers = %w[C c S s M m].map { |sin| Sashite::Sin.parse(sin) }

# Filter by player
first_player_identifiers = identifiers.select(&:first_player?)
first_player_identifiers.map(&:to_s) # => ["C", "S", "M"]

# Group by family
by_family = identifiers.group_by(&:family)
by_family[:C].size # => 2 (both C and c)

# Find specific families
chess_identifiers = identifiers.select { |i| i.family == :C }
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

SIN encodes style attributes using the following correspondence:

| Style Attribute | SIN Encoding | Examples |
|-----------------|--------------|----------|
| **Family** | Style family symbol | `:C`, `:S`, `:X` |
| **Side** | Player assignment | `:first`, `:second` |
| **Letter** | Combined representation | `"C"`, `"c"`, `"S"`, `"s"` |

#### Dual-Purpose Encoding

The **Letter** combines two distinct semantic components:
- **Style Family**: The underlying family symbol (:A-:Z), representing the game tradition or rule system
- **Player Assignment**: The side (:first or :second), encoded as case in the letter representation

**Examples**:
- Family `:C` + Side `:first` → Letter `"C"` (Chess, First player)
- Family `:C` + Side `:second` → Letter `"c"` (Chess, Second player)
- Family `:S` + Side `:first` → Letter `"S"` (Shōgi, First player)
- Family `:S` + Side `:second` → Letter `"s"` (Shōgi, Second player)

## Traditional Game Style Examples

The SIN specification is rule-agnostic and does not define specific letter assignments. However, here are common usage patterns following [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/):

```ruby
# Chess (8×8 board)
chess_white = Sashite::Sin.parse("C")    # First player (White pieces)
chess_black = Sashite::Sin.parse("c")    # Second player (Black pieces)

# Shōgi (9×9 board)
shogi_sente = Sashite::Sin.parse("S")    # First player (Sente 先手)
shogi_gote = Sashite::Sin.parse("s")     # Second player (Gote 後手)

# Xiangqi (9×10 board)
xiangqi_red = Sashite::Sin.parse("X")    # First player (Red pieces)
xiangqi_black = Sashite::Sin.parse("x")  # Second player (Black pieces)

# Makruk (8×8 board)
makruk_white = Sashite::Sin.parse("M")   # First player (White pieces)
makruk_black = Sashite::Sin.parse("m")   # Second player (Black pieces)

# Janggi (9×10 board)
janggi_cho = Sashite::Sin.parse("J")     # First player (Cho 초)
janggi_han = Sashite::Sin.parse("j")     # Second player (Han 한)
```

## Cross-Style Scenarios

```ruby
# Chess vs. Ōgi Match (both 8×8 compatible)
chess_white = Sashite::Sin.parse("C")    # Chess style, first player
ogi_black = Sashite::Sin.parse("o")      # Ōgi style, second player

# Cross-Style Match Setup
def create_hybrid_match
  [
    Sashite::Sin.parse("C"),             # First player uses Chess family
    Sashite::Sin.parse("s")              # Second player uses Shōgi family
  ]
end

identifiers = create_hybrid_match
identifiers[0].same_side?(identifiers[1])    # => false (different players)
identifiers[0].same_family?(identifiers[1])  # => false (different families)
```

## System Constraints

### Character Limitation
SIN provides **26 possible identifiers** per player using ASCII letters (A-Z, a-z).

### Player Limitation
SIN supports exactly **two players** through case distinction:
- **First player**: Uppercase letters (A-Z) → `:first`
- **Second player**: Lowercase letters (a-z) → `:second`

### Context Dependency
The specific SIN assignment for a style may vary between different game contexts based on collision avoidance, historical precedence, and community conventions.

## API Reference

### Main Module Methods

- `Sashite::Sin.valid?(sin_string)` - Check if string is valid SIN notation
- `Sashite::Sin.parse(sin_string)` - Parse SIN string into Identifier object
- `Sashite::Sin.identifier(family, side)` - Create identifier instance directly

### Identifier Class

#### Creation and Parsing
- `Sashite::Sin::Identifier.new(family, side)` - Create identifier instance
- `Sashite::Sin::Identifier.parse(sin_string)` - Parse SIN string

#### Attribute Access
- `#family` - Get style family (symbol :A through :Z)
- `#side` - Get player side (:first or :second)
- `#letter` - Get combined letter representation (string)
- `#to_s` - Convert to SIN string representation

#### Player Queries
- `#first_player?` - Check if first player identifier
- `#second_player?` - Check if second player identifier

#### Transformations (immutable - return new instances)
- `#flip` - Switch player assignment
- `#with_family(new_family)` - Create identifier with different family
- `#with_side(new_side)` - Create identifier with different side

#### Comparison Methods
- `#same_family?(other)` - Check if same style family
- `#same_side?(other)` - Check if same player side
- `#==(other)` - Full equality comparison
- `#same_letter?(other)` - Alias for `same_family?` (deprecated)

### Constants

- `Sashite::Sin::Identifier::FIRST_PLAYER` - Symbol for first player (`:first`)
- `Sashite::Sin::Identifier::SECOND_PLAYER` - Symbol for second player (`:second`)
- `Sashite::Sin::Identifier::VALID_FAMILIES` - Array of valid families (`:A` to `:Z`)
- `Sashite::Sin::Identifier::VALID_SIDES` - Array of valid sides
- `Sashite::Sin::Identifier::SIN_PATTERN` - Regular expression for SIN validation

## Advanced Usage

### Family and Side Separation

```ruby
# Clear separation of concerns
identifier = Sashite::Sin.parse("C")
identifier.family  # => :C (Style Family - invariant)
identifier.side    # => :first (Player Assignment)
identifier.letter  # => "C" (Combined representation)

# Transformations are explicit
chess_white = Sashite::Sin.identifier(:C, :first)
shogi_white = chess_white.with_family(:S) # Change family, keep side
chess_black = chess_white.with_side(:second) # Change side, keep family
```

### Immutable Transformations

```ruby
# All transformations return new instances
original = Sashite::Sin.identifier(:C, :first)
flipped = original.flip
changed_family = original.with_family(:S)

# Original identifier is never modified
original.to_s         # => "C" (unchanged)
flipped.to_s          # => "c"
changed_family.to_s   # => "S"

# Transformations can be chained
result = original.flip.with_family(:M).flip
result.to_s # => "M"
```

## Design Properties

Following the SIN v1.0.0 specification, this implementation provides:

- **ASCII compatibility**: Maximum portability across systems
- **Rule-agnostic**: Independent of specific game mechanics
- **Minimal overhead**: Single character per style-player combination
- **Flexible collision resolution**: Systematic approaches for identifier conflicts
- **Semantic clarity**: Distinct concepts for Family, Side, and Letter
- **SNN coordination**: Works harmoniously with formal style naming
- **Context-aware**: Adapts to avoid conflicts within specific game scenarios
- **Canonical representation**: Each style-player combination has exactly one SIN identifier
- **Immutable**: All identifier instances are frozen and transformations return new objects
- **Functional**: Pure functions with no side effects

## Related Specifications

- [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) - Complete technical specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) - Practical implementation examples
- [Style Name Notation (SNN)](https://sashite.dev/specs/snn/) - Formal naming for game styles
- [Sashité Protocol](https://sashite.dev/protocol/) - Conceptual foundation for abstract strategy board games

## Documentation

- [Official SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/)
- [SIN Examples Documentation](https://sashite.dev/specs/sin/1.0.0/examples/)
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

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
