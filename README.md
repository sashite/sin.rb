# sin.rb

[![Version](https://img.shields.io/github/v/tag/sashite/sin.rb?label=Version&logo=github)](https://github.com/sashite/sin.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/sin.rb/main)
[![CI](https://github.com/sashite/sin.rb/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/sashite/sin.rb/actions)
[![License](https://img.shields.io/github/license/sashite/sin.rb?label=License&logo=github)](https://github.com/sashite/sin.rb/raw/main/LICENSE)

> **SIN** (Style Identifier Notation) implementation for Ruby.

## Overview

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

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

### Parsing (String → Identifier)

Convert a SIN string into an `Identifier` object.

```ruby
require "sashite/sin"

# Standard parsing (raises on error)
sin = Sashite::Sin.parse("C")
sin.style  # => :C
sin.side   # => :first

# Lowercase indicates second player
sin = Sashite::Sin.parse("c")
sin.style  # => :C
sin.side   # => :second

# Invalid input raises ArgumentError
Sashite::Sin.parse("")    # => raises ArgumentError
Sashite::Sin.parse("CC")  # => raises ArgumentError
```

### Formatting (Identifier → String)

Convert an `Identifier` back to a SIN string.

```ruby
# From Identifier object
sin = Sashite::Sin::Identifier.new(:C, :first)
sin.to_s  # => "C"

sin = Sashite::Sin::Identifier.new(:C, :second)
sin.to_s  # => "c"
```

### Validation

```ruby
# Boolean check
Sashite::Sin.valid?("C")   # => true
Sashite::Sin.valid?("c")   # => true
Sashite::Sin.valid?("")    # => false
Sashite::Sin.valid?("CC")  # => false
Sashite::Sin.valid?("1")   # => false
```

### Accessing Identifier Data

```ruby
sin = Sashite::Sin.parse("C")

# Get attributes
sin.style  # => :C
sin.side   # => :first

# Get string component
sin.letter  # => "C"
```

### Transformations

All transformations return new immutable `Identifier` objects.

```ruby
sin = Sashite::Sin.parse("C")

# Side transformation
sin.flip.to_s  # => "c"

# Attribute changes
sin.with_style(:S).to_s  # => "S"
sin.with_side(:second).to_s  # => "c"
```

### Queries

```ruby
sin = Sashite::Sin.parse("C")

# Side queries
sin.first_player?   # => true
sin.second_player?  # => false

# Comparison queries
other = Sashite::Sin.parse("c")
sin.same_style?(other)  # => true
sin.same_side?(other)   # => false
```

## API Reference

### Types

```ruby
# Identifier represents a parsed SIN identifier with style and side.
class Sashite::Sin::Identifier
  # Creates an Identifier from style and side.
  # Raises ArgumentError if attributes are invalid.
  #
  # @param style [Symbol] Style abbreviation (:A through :Z)
  # @param side [Symbol] Player side (:first or :second)
  # @return [Identifier]
  def initialize(style, side)

  # Returns the style as an uppercase symbol.
  #
  # @return [Symbol]
  def style

  # Returns the player side.
  #
  # @return [Symbol] :first or :second
  def side

  # Returns the SIN string representation.
  #
  # @return [String]
  def to_s
end
```

### Constants

```ruby
Sashite::Sin::Identifier::VALID_STYLES  # => [:A, :B, ..., :Z]
Sashite::Sin::Identifier::VALID_SIDES   # => [:first, :second]
```

### Parsing

```ruby
# Parses a SIN string into an Identifier.
# Raises ArgumentError if the string is not valid.
#
# @param string [String] SIN string
# @return [Identifier]
# @raise [ArgumentError] if invalid
def Sashite::Sin.parse(string)
```

### Validation

```ruby
# Reports whether string is a valid SIN identifier.
#
# @param string [String] SIN string
# @return [Boolean]
def Sashite::Sin.valid?(string)
```

### Transformations

All transformations return new `Sashite::Sin::Identifier` objects:

```ruby
# Side transformation
def flip  # => Identifier

# Attribute changes
def with_style(style)  # => Identifier
def with_side(side)    # => Identifier
```

### Queries

```ruby
# Side queries
def first_player?   # => Boolean
def second_player?  # => Boolean

# Comparison queries
def same_style?(other)  # => Boolean
def same_side?(other)   # => Boolean
```

### Errors

All parsing and validation errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"empty input"` | String length is 0 |
| `"input exceeds 1 character"` | String too long |
| `"must be a letter"` | Character is not A-Z or a-z |

## Design Principles

- **Bounded values**: Explicit validation of styles and sides
- **Object-oriented**: `Identifier` class enables methods and encapsulation
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **Immutable identifiers**: All transformations return new objects
- **No dependencies**: Pure Ruby standard library only

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
