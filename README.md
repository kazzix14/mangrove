# Mangrove

Mangrove is a Ruby Gem designed to be the definitive toolkit for leveraging Sorbet's type system in Ruby applications. It's designed to offer a robust, statically-typed experience, focusing on solid types, a functional programming style, and an interface-driven approach.

- [Documentation](https://kazzix14.github.io/mangrove/docs/)
- [Coverage](https://kazzix14.github.io/mangrove/coverage/index.html#_AllFiles)

## Features

- Option Type
- Result Type
- Enums with inner types (ADTs)

## Installation

```
bundle add mangrove
```

## Usage

[Documentation is available here](https://kazzix14.github.io/mangrove/docs).
For more concrete examples, see [`spec/**/**_spec.rb`](https://github.com/kazzix14/mangrove/tree/main/spec).

```ruby
Mangrove::Result[OkType, ErrType]
Mangrove::Result::Ok[OkType, ErrType]
Mangrove::Result::Err[OkType, ErrType]
Mangrove::Option[InnerType]
Mangrove::Option::Some[InnerType]
Mangrove::Option::None[InnerType]

my_ok = Result::Ok.new("my value")
my_err = Result::Err.new("my err")
my_some = Option::Some.new(1234)
my_none = Option::None.new

##############################

response = MyClient
  .new
  .and_then { |client| client.get_response() }
  .and_then { |response| response.body }

case response
when Mangrove::Result::Ok
  puts response.ok_inner
when Mangrove::Result::Err
  puts response.err_inner
end

##############################

class MyEnum
  extend Mangrove::Enum

  variants do
    variant VariantWithInteger, Integer
    variant VariantWithString, String
    variant VariantWithException, Exception
    variant VariantWithTuple, [Integer, String]
    variant VariantWithShape, { name: String, age: Integer }
  end
end
```

## Commands for Development

```
git config core.hooksPath hooks
bundle install
bundle exec tapioca init
bundle exec tapioca gems -w `nproc`
bundle exec tapioca dsl -w `nproc`
bundle exec tapioca check-shims
bundle exec tapioca init
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
