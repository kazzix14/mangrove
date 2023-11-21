# Mangrove
Mangrove provides type utility to use with Sorbet.

Mangrove is a Ruby Gem designed to be the definitive toolkit for leveraging Sorbet's type system in Ruby applications. It's designed to offer a robust, statically-typed experience, focusing on solid types, a functional programming style, and an interface-driven approach.

Use `rubocop-mangrove` to statically check rescuing ControlSignal is done

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

[Documentation is available here](https://kazzix14.github.io/mangrove/).
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
bundle exec spoom tc
bundle exec ordinare --check
bundle exec ruboclean
bundle exec yardoc -o docs/ --plugin yard-sorbet
rake build
rake release
```
