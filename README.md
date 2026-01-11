# Sashite::Sin

[![Version](https://img.shields.io/github/v/tag/sashite/sin.rb?label=Version&logo=github)](https://github.com/sashite/sin.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/sin.rb/main)
[![CI](https://github.com/sashite/sin.rb/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/sashite/sin.rb/actions)
[![License](https://img.shields.io/github/license/sashite/sin.rb?label=License&logo=github)](https://github.com/sashite/sin.rb/raw/main/LICENSE)

> **SIN** (Style Identifier Notation) implementation for Ruby.

## What is SIN?

SIN (Style Identifier Notation) provides a compact, ASCII-based format for encoding **Piece Style** with an associated **Side** in abstract strategy board games. It serves as a minimal building block that can be embedded in higher-level notations.

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

## Installation

Add `sashite-sin` to your Gemfile:

```ruby
gem "sashite-sin"
```

Or install manually:

```sh
gem install sashite-sin
```

## Usage

```ruby
require "sashite/sin"

# Parse SIN strings
sin = Sashite::Sin.parse("C")
sin.style  # => :C
sin.side   # => :first

sin.to_s  # => "C"

# Parse with different styles and sides
chess_first = Sashite::Sin.parse("C")   # Chess-style, first player
chess_second = Sashite::Sin.parse("c")  # Chess-style, second player
shogi_first = Sashite::Sin.parse("S")   # Shogi-style, first player

# Create identifiers directly
sin = Sashite::Sin.new(:C, :first)
sin = Sashite::Sin.new(:S, :second)

# Validation
Sashite::Sin.valid?("C")        # => true
Sashite::Sin.valid?("s")        # => true
Sashite::Sin.valid?("CC")       # => false (more than one character)
Sashite::Sin.valid?("1")        # => false (digit instead of letter)
Sashite::Sin.valid?("")         # => false (empty string)

# Side transformation
flipped = sin.flip
flipped.to_s  # => "s"

# Attribute changes
shogi = sin.with_style(:S)
shogi.to_s  # => "S"

second = sin.with_side(:second)
second.to_s  # => "c"

# Side queries
sin.first_player?     # => true
sin.second_player?    # => false

# Comparison
chess1 = Sashite::Sin.parse("C")
chess2 = Sashite::Sin.parse("c")

Sashite::Sin.same_style?(chess1, chess2)  # => true
Sashite::Sin.same_side?(chess1, chess2)   # => false
```

## Format Specification

### Structure

```
<letter>
```

A SIN token is **exactly one** ASCII letter (`A-Z` or `a-z`).

### Attribute Mapping

| Attribute | Encoding |
|-----------|----------|
| Piece Style | Base letter (case-insensitive): `C` and `c` represent the same style |
| Side | Letter case: uppercase → `first`, lowercase → `second` |

### Side Convention

- **Uppercase** (`A-Z`): First player (Side `first`)
- **Lowercase** (`a-z`): Second player (Side `second`)

### Common Conventions

| SIN | Side | Typical Piece Style |
|-----|------|---------------------|
| `C` | First | Chess-style |
| `c` | Second | Chess-style |
| `S` | First | Shogi-style |
| `s` | Second | Shogi-style |
| `X` | First | Xiangqi-style |
| `x` | Second | Xiangqi-style |
| `M` | First | Makruk-style |
| `m` | Second | Makruk-style |

### Invalid Token Examples

| String | Reason |
|--------|--------|
| `""` | Empty string |
| `CC` | More than one character |
| `c1` | Contains a digit |
| `+C` | Contains a prefix character |
| ` C` | Leading whitespace |
| `C ` | Trailing whitespace |
| `1` | Digit instead of letter |
| `é` | Non-ASCII character |

## API Reference

### Parsing

```ruby
Sashite::Sin.parse(sin_string)   # => Sashite::Sin instance or raises ArgumentError
Sashite::Sin.valid?(sin_string)  # => boolean
```

### Creation

```ruby
Sashite::Sin.new(style, side)
```

### Conversion

```ruby
sin.to_s     # => String
sin.letter   # => String (the single character)
```

### Transformations

All transformations return new `Sashite::Sin` instances:

```ruby
# Side
sin.flip

# Attribute changes
sin.with_style(new_style)
sin.with_side(new_side)
```

### Queries

```ruby
# Side
sin.first_player?
sin.second_player?

# Comparison
sin.same_style?(other)
sin.same_side?(other)
```

## Data Structure

```ruby
Sashite::Sin.new(style, side)
# style: Symbol (:A through :Z) - Piece style (always uppercase symbol)
# side:  Symbol (:first or :second) - Player side
```

## Protocol Mapping

Following the [Game Protocol](https://sashite.dev/game-protocol/):

| Protocol Attribute | SIN Encoding |
|-------------------|--------------|
| Piece Style | Base letter (case-insensitive) |
| Piece Side | Letter case |

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
