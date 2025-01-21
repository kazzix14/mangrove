# Mangrove

Mangrove is a Ruby toolkit that brings a functional, statically-typed flavor to your Sorbet-enabled projects. Inspired by concepts from languages like Rust and Haskell, Mangrove provides a robust set of tools—primarily `Result` and ADT-like Enums—to help you write safer, more expressive Ruby code.

- **[Documentation](https://kazzix14.github.io/mangrove/docs/)**
- **[Coverage](https://kazzix14.github.io/mangrove/coverage/index.html#_AllFiles)**

---

## Highlights

- **Sorbet Integration**
  Built from the ground up to work smoothly with Sorbet’s type system.

- **Result Type**
  Model success/failure outcomes with explicit types—no more “return false or nil” for errors!

- **Enums (ADTs)**
  Define your own sealed enums with typed variants. Each variant can hold distinct inner data.

- **Functional Patterns**
  Chain transformations or short-circuit error handling with a clean monadic style.

---

## Installation

```bash
bundle add mangrove
```

---

## Usage Overview

Mangrove revolves around **`Result`** and a sealed “Enum” mechanism for ADTs.

### Result

A `Result` is either `Ok(T)` or `Err(E)`. You can compose them with monadic methods like `and_then` and `or_else`.
For “early returns” in a functional style, you have two main approaches:

1. **A context-based DSL (e.g., `ctx.try!`)**
2. **An instance method on `Result` itself, `unwrap_in(ctx)`**, which behaves similarly.

Here’s an example of chaining requests and short-circuiting on error:

```ruby
class MyClient
  extend T::Sig

  sig { returns(Mangrove::Result[String, StandardError]) }
  def connect
    # ...
    Mangrove::Result::Ok.new("Connected")
  end

  sig { params(data: String).returns(Mangrove::Result[String, StandardError]) }
  def request(data)
    # ...
    Mangrove::Result::Ok.new("Response: #{data}")
  end
end

# Let's say we have a special DSL context for collecting short-circuits:
# (Hypothetical usage)

ctx = SomeCollectingContext.new

final_result = MyClient.new
  .connect
  .and_then do |connection|
    MyClient.new.request("Payload from #{connection}")
  end

# Option 1: Call from the context
response_data = ctx.try!(final_result)
# => If 'final_result' is Err, short-circuits now;
#    otherwise returns the Ok(T) value.

puts response_data  # If no errors, prints "Response: Connected"

# Option 2: Call via 'unwrap_in(ctx)'
# This does the same short-circuit if 'Err', using the context:
response_data_alt = final_result.unwrap_in(ctx)

# More chaining, etc...
```

### Enums (ADTs)

Define an enum with typed variants:

```ruby
class MyEnum
  extend Mangrove::Enum

  variants do
    variant IntVariant, Integer
    variant StrVariant, String
    variant ShapeVariant, { name: String, age: Integer }
  end
end

int_v = MyEnum::IntVariant.new(123)
puts int_v.inner  # => 123
```

For more details on monadic methods, short-circuit contexts, and advanced usage, please visit the [official documentation](https://kazzix14.github.io/mangrove/docs/) or see real-world usages in [`spec/`](https://github.com/kazzix14/mangrove/tree/main/spec).

---

## Example: Monadic Control Flow

A quick snippet showing how you might short-circuit in a pseudo “collecting” DSL:

```ruby
class CollectingContext
  extend T::Sig

  # short-circuits if given an Err
  sig { type_parameters(:O, :E).params(result: Mangrove::Result[T.type_parameter(:O), T.type_parameter(:E)]).returns(T.type_parameter(:O)) }
  def try!(result)
    case result
    when Mangrove::Result::Ok
      result.ok_inner
    when Mangrove::Result::Err
      # short-circuit out
      throw :return, result.err_inner
    end
  end
end

# Suppose we wrap this with a .collecting that uses catch(:return) to intercept the short-circuit.
return_value = Mangrove::Result.collecting(String, StandardError) do |ctx|
  part1 = ctx.try!(MyClient.new.connect)
  part2 = ctx.try!(MyClient.new.request("More data"))
  Mangrove::Result::Ok.new("#{part1} => #{part2}")
end

# If everything is Ok, 'return_value' might be something like:
# => Mangrove::Result::Ok("Connected => Response: More data")
# If an error occurs, it short-circuits with that error's inner value.
```

---

## Commands for Development

```bash
git config core.hooksPath hooks
bundle install
bundle exec tapioca init
bundle exec tapioca gems -w `nproc`
bundle exec tapioca dsl -w `nproc`
bundle exec tapioca check-shims
bundle exec rspec -f d
bundle exec rubocop -DESP
bundle exec srb typecheck
bundle exec spoom srb tc
bundle exec ordinare --check
bundle exec ruboclean --verify
bundle exec yardoc -o docs/ --plugin yard-sorbet
bundle exec yard server --reload --plugin yard-sorbet
rake build
rake release
```

Run these commands to maintain code quality, generate documentation, and verify type safety under Sorbet.

---

## Contributing

We welcome contributions! To get started:

1. Fork & clone the repo
2. Install dependencies: ```bash
bundle install
```
3. Make your changes and add tests
4. Submit a PR

---

## License

Mangrove is available under the [MIT License](https://opensource.org/licenses/MIT). See the LICENSE file for details.
