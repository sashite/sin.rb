# sin.rb

[![Version](https://img.shields.io/github/v/tag/sashite/sin.rb?label=Version&logo=github)](https://github.com/sashite/sin.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/sin.rb/main)
[![CI](https://github.com/sashite/sin.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/sin.rb/actions)
[![License](https://img.shields.io/github/license/sashite/sin.rb?label=License&logo=github)](https://github.com/sashite/sin.rb/raw/main/LICENSE)

> **SIN** (Style Identifier Notation) implementation for Ruby.

## Overview

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

SIN is a single-character, ASCII-only token format encoding a **Player Identity**: the tuple (**Player Side**, **Player Style**). Uppercase indicates the first player, lowercase indicates the second player.

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Token length | Exactly 1 | Single ASCII letter per spec |
| Character space | A–Z, a–z | 52 total tokens (26 abbreviations × 2 sides) |
| Instance pool | 52 objects | All identifiers are pre-instantiated and frozen |

The closed domain of 52 possible values enables a flyweight architecture with zero allocation on the hot path.

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
sin.abbr  # => :C
sin.side  # => :first

# Lowercase indicates second player
sin = Sashite::Sin.parse("c")
sin.abbr  # => :C
sin.side  # => :second

# Returns a cached instance — no allocation
Sashite::Sin.parse("C").equal?(Sashite::Sin.parse("C"))  # => true

# Invalid input raises ArgumentError
Sashite::Sin.parse("")    # => raises ArgumentError
Sashite::Sin.parse("CC")  # => raises ArgumentError
```

### Safe Parsing (String → Identifier | nil)

Parse without raising exceptions. Returns `nil` on invalid input.

```ruby
# Valid input returns an Identifier
Sashite::Sin.safe_parse("C")   # => #<Sashite::Sin::Identifier C>
Sashite::Sin.safe_parse("c")   # => #<Sashite::Sin::Identifier c>

# Invalid input returns nil — no exception allocated
Sashite::Sin.safe_parse("")    # => nil
Sashite::Sin.safe_parse("CC")  # => nil
Sashite::Sin.safe_parse("1")   # => nil
Sashite::Sin.safe_parse(nil)   # => nil
```

### Fetching by Components (Symbol, Symbol → Identifier)

Retrieve a cached identifier directly by abbreviation and side, bypassing string parsing entirely.

```ruby
# Direct lookup — no string parsing, no allocation
Sashite::Sin.fetch(:C, :first)   # => #<Sashite::Sin::Identifier C>
Sashite::Sin.fetch(:C, :second)  # => #<Sashite::Sin::Identifier c>

# Same cached instance as parse
Sashite::Sin.fetch(:C, :first).equal?(Sashite::Sin.parse("C"))  # => true

# Invalid components raise ArgumentError
Sashite::Sin.fetch(:CC, :first)    # => raises ArgumentError
Sashite::Sin.fetch(:C, :third)     # => raises ArgumentError
```

### Formatting (Identifier → String)

Convert an `Identifier` back to a SIN string.

```ruby
sin = Sashite::Sin.parse("C")
sin.to_s  # => "C"

sin = Sashite::Sin.parse("c")
sin.to_s  # => "c"
```

### Validation

```ruby
# Boolean check (never raises)
# Uses an exception-free code path internally for performance.
Sashite::Sin.valid?("C")   # => true
Sashite::Sin.valid?("c")   # => true
Sashite::Sin.valid?("")    # => false
Sashite::Sin.valid?("CC")  # => false
Sashite::Sin.valid?("1")   # => false
Sashite::Sin.valid?(nil)   # => false
```

### Queries

```ruby
sin = Sashite::Sin.parse("C")

# Side queries
sin.first_player?   # => true
sin.second_player?  # => false

# Comparison queries
other = Sashite::Sin.parse("c")
sin.same_abbr?(other)  # => true
sin.same_side?(other)  # => false
```

## API Reference

### Module Methods

```ruby
# Parses a SIN string into a cached Identifier.
# Returns a pre-instantiated, frozen instance.
# Raises ArgumentError if the string is not valid.
#
# @param string [String] SIN string
# @return [Identifier]
# @raise [ArgumentError] if invalid
def Sashite::Sin.parse(string)

# Parses a SIN string without raising.
# Returns a cached Identifier on success, nil on failure.
# Never allocates exception objects or captures backtraces.
#
# @param string [String] SIN string
# @return [Identifier, nil]
def Sashite::Sin.safe_parse(string)

# Retrieves a cached Identifier by abbreviation and side.
# Bypasses string parsing entirely — direct hash lookup.
# Raises ArgumentError if components are invalid.
#
# @param abbr [Symbol] Style abbreviation (:A through :Z)
# @param side [Symbol] Player side (:first or :second)
# @return [Identifier]
# @raise [ArgumentError] if invalid
def Sashite::Sin.fetch(abbr, side)

# Reports whether string is a valid SIN identifier.
# Never raises; returns false for any invalid input.
# Uses an exception-free code path internally for performance.
#
# @param string [String] SIN string
# @return [Boolean]
def Sashite::Sin.valid?(string)
```

### Identifier

```ruby
# Identifier represents a parsed SIN identifier with abbreviation and side.
# All instances are frozen and pre-instantiated — never construct directly,
# use Sashite::Sin.parse, .safe_parse, or .fetch instead.
class Sashite::Sin::Identifier
  # Returns the style abbreviation as an uppercase symbol.
  #
  # @return [Symbol] :A through :Z
  def abbr

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

### Queries

```ruby
# Side queries
def first_player?   # => Boolean
def second_player?  # => Boolean

# Comparison queries
def same_abbr?(other)  # => Boolean
def same_side?(other)  # => Boolean
```

### Constants

```ruby
Sashite::Sin::Identifier::VALID_ABBRS  # => [:A, :B, ..., :Z]
Sashite::Sin::Identifier::VALID_SIDES  # => [:first, :second]
```

### Errors

All errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"empty input"` | String length is 0 |
| `"input exceeds 1 character"` | String too long |
| `"must be a letter"` | Character is not A-Z or a-z |

## Design Principles

- **Spec conformance**: Strict adherence to SIN v1.0.0
- **Flyweight identifiers**: All 52 possible instances are pre-built and frozen; parsing and fetching return cached objects with zero allocation
- **Performance-oriented internals**: Exception-free validation path; exceptions only at the public API boundary
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **Immutable identifiers**: All instances are frozen after creation
- **No dependencies**: Pure Ruby standard library only

### Performance Architecture

SIN has a closed domain of exactly 52 valid tokens (26 letters × 2 cases). The implementation exploits this constraint through two complementary strategies.

**Flyweight instance pool** — All 52 `Identifier` objects are pre-instantiated and frozen at load time. `parse`, `safe_parse`, and `fetch` return these cached instances via hash lookup. No `Identifier` is ever allocated after the module loads. This makes SIN essentially free to call from FEEN or any other hot loop — every call is a hash lookup returning a pre-existing frozen object.

**Dual-path parsing** — Parsing is split into two layers to avoid using exceptions for control flow:

- **Validation layer** — `safe_parse` performs all validation and returns the cached `Identifier` on success, or `nil` on failure, without raising, without allocating exception objects, and without capturing backtraces.
- **Public API layer** — `parse` calls `safe_parse` internally. On failure, it raises `ArgumentError` exactly once, at the boundary. `valid?` calls `safe_parse` and returns a boolean directly, never raising.

**Direct component lookup** — `fetch` bypasses string parsing entirely. Given a symbol pair `(:C, :first)`, it performs a single hash lookup into the instance pool. This is the fastest path for callers that already have structured data (e.g., FEEN's dumper reconstructing a style–turn field from `Qi` attributes).

This architecture ensures that SIN never becomes a bottleneck when called from higher-level parsers like FEEN, where it may be invoked multiple times per position.

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
