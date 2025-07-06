# Snn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/snn.rb?label=Version&logo=github)](https://github.com/sashite/snn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/snn.rb/main)
![Ruby](https://github.com/sashite/snn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/snn.rb?label=License&logo=github)](https://github.com/sashite/snn.rb/raw/main/LICENSE.md)

> **SNN** (Style Name Notation) implementation for the Ruby language.

## What is SNN?

SNN (Style Name Notation) provides a compact, ASCII-based format for identifying **styles** in abstract strategy board games. SNN uses single-character identifiers with case encoding to represent both style identity and player assignment simultaneously.

This gem implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/), providing a rule-agnostic notation system for style identification in board games.

## Installation

```ruby
# In your Gemfile
gem "sashite-snn"
```

Or install manually:

```sh
gem install sashite-snn
```

## Usage

### Basic Operations

```ruby
require "sashite/snn"

# Parse SNN strings into style objects
style = Sashite::Snn.parse("C")           # => #<Snn::Style letter=:C side=:first>
style.to_s                                # => "C"
style.letter                              # => :C
style.side                                # => :first

# Create styles directly
style = Sashite::Snn.style(:C, :first)           # => #<Snn::Style letter=:C side=:first>
style = Sashite::Snn::Style.new(:c, :second)     # => #<Snn::Style letter=:c side=:second>

# Validate SNN strings
Sashite::Snn.valid?("C")                 # => true
Sashite::Snn.valid?("c")                 # => true
Sashite::Snn.valid?("1")                 # => false (not a letter)
Sashite::Snn.valid?("CC")                # => false (not single character)
```

### Style Transformations

```ruby
# All transformations return new immutable instances
style = Sashite::Snn.parse("C")

# Flip player assignment
flipped = style.flip                      # => #<Snn::Style letter=:c side=:second>
flipped.to_s                              # => "c"

# Change letter
changed = style.with_letter(:S)           # => #<Snn::Style letter=:S side=:first>
changed.to_s                              # => "S"

# Change side
other_side = style.with_side(:second)     # => #<Snn::Style letter=:c side=:second>
other_side.to_s                           # => "c"

# Chain transformations
result = style.flip.with_letter(:M)       # => #<Snn::Style letter=:m side=:second>
result.to_s                               # => "m"
```

### Player and Style Queries

```ruby
style = Sashite::Snn.parse("C")
opposite = Sashite::Snn.parse("s")

# Player identification
style.first_player?                       # => true
style.second_player?                      # => false
opposite.first_player?                    # => false
opposite.second_player?                   # => true

# Letter comparison
chess1 = Sashite::Snn.parse("C")
chess2 = Sashite::Snn.parse("c")
shogi = Sashite::Snn.parse("S")

chess1.same_letter?(chess2)               # => true (both use letter C)
chess1.same_side?(shogi)                  # => true (both first player)
chess1.same_letter?(shogi)                # => false (different letters)
```

### Style Collections

```ruby
# Working with multiple styles
styles = %w[C c S s M m].map { |snn| Sashite::Snn.parse(snn) }

# Filter by player
first_player_styles = styles.select(&:first_player?)
first_player_styles.map(&:to_s)          # => ["C", "S", "M"]

# Group by letter family
by_letter = styles.group_by { |s| s.letter.to_s.upcase }
by_letter["C"].size                       # => 2 (both C and c)

# Find specific combinations
chess_styles = styles.select { |s| s.letter.to_s.upcase == "C" }
chess_styles.map(&:to_s)                  # => ["C", "c"]
```

## Format Specification

### Structure
```
<style-letter>
```

### Grammar (BNF)
```bnf
<snn> ::= <uppercase-letter> | <lowercase-letter>

<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
```

### Regular Expression
```ruby
/\A[A-Za-z]\z/
```

### Style Attribute Mapping

| Style Attribute | SNN Encoding | Examples |
|-----------------|--------------|----------|
| **Style Family** | Letter choice | `C`/`c` = Chess family |
| **Player Assignment** | Letter case | `C` = First player, `c` = Second player |

## Game Examples

The SNN specification is rule-agnostic and does not define specific letter assignments. However, here are common usage patterns:

### Traditional Game Families

```ruby
# Chess family styles
chess_white = Sashite::Snn.parse("C")    # First player, Chess family
chess_black = Sashite::Snn.parse("c")    # Second player, Chess family

# Shōgi family styles
shogi_sente = Sashite::Snn.parse("S")    # First player, Shōgi family
shogi_gote = Sashite::Snn.parse("s")     # Second player, Shōgi family

# Xiangqi family styles
xiangqi_red = Sashite::Snn.parse("X")    # First player, Xiangqi family
xiangqi_black = Sashite::Snn.parse("x")  # Second player, Xiangqi family
```

### Cross-Style Scenarios

```ruby
# Different families in one match
def create_hybrid_match
  [
    Sashite::Snn.parse("C"),             # First player uses Chess family
    Sashite::Snn.parse("s")              # Second player uses Shōgi family
  ]
end

styles = create_hybrid_match
styles[0].same_side?(styles[1])         # => false (different players)
styles[0].same_letter?(styles[1])       # => false (different families)
```

### Variant Families

```ruby
# Different letters can represent variants within traditions
makruk = Sashite::Snn.parse("M")        # Makruk (Thai Chess) family
janggi = Sashite::Snn.parse("J")        # Janggi (Korean Chess) family
ogi = Sashite::Snn.parse("O")           # Ōgi (王棋) family

# Each family can have both players
makruk_black = makruk.flip              # Second player Makruk
makruk_black.to_s                       # => "m"
```

## API Reference

### Main Module Methods

- `Sashite::Snn.valid?(snn_string)` - Check if string is valid SNN notation
- `Sashite::Snn.parse(snn_string)` - Parse SNN string into Style object
- `Sashite::Snn.style(letter, side)` - Create style instance directly

### Style Class

#### Creation and Parsing
- `Sashite::Snn::Style.new(letter, side)` - Create style instance
- `Sashite::Snn::Style.parse(snn_string)` - Parse SNN string

#### Attribute Access
- `#letter` - Get style letter (symbol :A through :z)
- `#side` - Get player side (:first or :second)
- `#to_s` - Convert to SNN string representation

#### Player Queries
- `#first_player?` - Check if first player style
- `#second_player?` - Check if second player style

#### Transformations (immutable - return new instances)
- `#flip` - Switch player assignment
- `#with_letter(new_letter)` - Create style with different letter
- `#with_side(new_side)` - Create style with different side

#### Comparison Methods
- `#same_letter?(other)` - Check if same style letter (case-insensitive)
- `#same_side?(other)` - Check if same player side
- `#==(other)` - Full equality comparison

### Style Class Constants

- `Sashite::Snn::Style::FIRST_PLAYER` - Symbol for first player (:first)
- `Sashite::Snn::Style::SECOND_PLAYER` - Symbol for second player (:second)
- `Sashite::Snn::Style::VALID_SIDES` - Array of valid sides
- `Sashite::Snn::Style::SNN_PATTERN` - Regular expression for SNN validation

## Advanced Usage

### Letter Case and Side Mapping

```ruby
# SNN encodes player assignment through case
upper_case_letters = ("A".."Z").map { |letter| Sashite::Snn.parse(letter) }
lower_case_letters = ("a".."z").map { |letter| Sashite::Snn.parse(letter) }

# All uppercase letters are first player
upper_case_letters.all?(&:first_player?)     # => true

# All lowercase letters are second player
lower_case_letters.all?(&:second_player?)    # => true

# Letter families are related by case
letter_a_first = Sashite::Snn.parse("A")
letter_a_second = Sashite::Snn.parse("a")

letter_a_first.same_letter?(letter_a_second)  # => true
letter_a_first.same_side?(letter_a_second)    # => false
```

### Immutable Transformations

```ruby
# All transformations return new instances
original = Sashite::Snn.style(:C, :first)
flipped = original.flip
changed_letter = original.with_letter(:S)

# Original style is never modified
original.to_s                           # => "C" (unchanged)
flipped.to_s                            # => "c"
changed_letter.to_s                     # => "S"

# Transformations can be chained
result = original.flip.with_letter(:M).flip
result.to_s                             # => "M"
```

### Game Configuration Management

```ruby
class GameConfiguration
  def initialize
    @player_styles = {}
  end

  def set_player_style(player, letter)
    side = player == :white ? :first : :second
    @player_styles[player] = Sashite::Snn.style(letter, side)
  end

  def get_player_style(player)
    @player_styles[player]
  end

  def cross_family_match?
    return false if @player_styles.size < 2

    styles = @player_styles.values
    !styles.all? { |style| style.same_letter?(styles.first) }
  end

  def same_family_match?
    !cross_family_match?
  end
end

# Usage
config = GameConfiguration.new
config.set_player_style(:white, :C)    # Chess family, first player
config.set_player_style(:black, :S)    # Shōgi family, second player

config.cross_family_match?             # => true

white_style = config.get_player_style(:white)
white_style.to_s                       # => "C"
```

### Style Analysis

```ruby
def analyze_styles(snns)
  styles = snns.map { |snn| Sashite::Snn.parse(snn) }

  {
    total: styles.size,
    by_side: styles.group_by(&:side),
    by_letter: styles.group_by { |s| s.letter.to_s.upcase },
    unique_letters: styles.map { |s| s.letter.to_s.upcase }.uniq.size,
    cross_family: styles.map { |s| s.letter.to_s.upcase }.uniq.size > 1
  }
end

snns = %w[C c S s X x]
analysis = analyze_styles(snns)
analysis[:by_side][:first].size        # => 3
analysis[:unique_letters]              # => 3
analysis[:cross_family]                # => true
```

### Tournament Style Registry

```ruby
class TournamentStyleRegistry
  def initialize
    @registered_styles = Set.new
  end

  def register_letter(letter)
    # Register both sides of a letter family
    first_player_style = Sashite::Snn.style(letter.to_s.upcase.to_sym, :first)
    second_player_style = first_player_style.flip

    @registered_styles.add(first_player_style)
    @registered_styles.add(second_player_style)

    [first_player_style, second_player_style]
  end

  def valid_pairing?(style1, style2)
    @registered_styles.include?(style1) &&
    @registered_styles.include?(style2) &&
    !style1.same_side?(style2)
  end

  def available_styles_for_side(side)
    @registered_styles.select { |style| style.side == side }
  end

  def supported_families
    @registered_styles.map { |s| s.letter.to_s.upcase }.uniq.sort
  end
end

# Usage
registry = TournamentStyleRegistry.new
registry.register_letter(:C)
registry.register_letter(:S)

chess_white = Sashite::Snn.parse("C")
shogi_black = Sashite::Snn.parse("s")

registry.valid_pairing?(chess_white, shogi_black)  # => true
registry.supported_families                        # => ["C", "S"]
```

## Protocol Mapping

Following the [Sashité Protocol](https://sashite.dev/protocol/):

| Protocol Attribute | SNN Encoding | Examples | Notes |
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
- **Canonical representation**: Each style-player combination has exactly one SNN identifier
- **Immutable**: All style instances are frozen and transformations return new objects
- **Functional**: Pure functions with no side effects

## Related Specifications

- [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/) - Complete technical specification
- [SNN Examples](https://sashite.dev/specs/snn/1.0.0/examples/) - Practical implementation examples
- [Sashité Protocol](https://sashite.dev/protocol/) - Conceptual foundation for abstract strategy board games
- [PIN](https://sashite.dev/specs/pin/) - Piece Identifier Notation
- [PNN](https://sashite.dev/specs/pnn/) - Piece Name Notation (style-aware piece representation)
- [QPI](https://sashite.dev/specs/qpi/) - Qualified Piece Identifier

## Documentation

- [Official SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/)
- [SNN Examples Documentation](https://sashite.dev/specs/snn/1.0.0/examples/)
- [Sashité Protocol Foundation](https://sashite.dev/protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/snn.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/snn.rb.git
cd snn.rb

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
