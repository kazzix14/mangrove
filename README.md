# Mangrove
Mangrove provides type utility to use with Sorbet.

You can do something like this with the gem.

```ruby
class MyClass
  extend T::Sig

  include Mangrove::ControlFlow::Handler

  sig { params(numbers: T::Enumerable[Integer]).returns(Mangrove::Result[T::Array[Integer], String]) }
  def divide_arguments_by_3(numbers)
    divided_nubmers = numbers
      .map { |number|
        if number % 3 == 0
          Mangrove::Result::Ok.new(number / 3)
        else
          Mangrove::Result::Err.new("number #{number} is not divisible by 3")
        end
      }
      .map(&:unwrap!)

    Mangrove::Result::Ok.new(divided_nubmers)
  end
end

expect(MyClass.new.divide_arguments_by_3([3, 4, 6])).to eq Mangrove::Result::Err.new("number 4 is not divisible by 3")
expect(MyClass.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])
```

Other examples are available at [`spec/**/**_spec.rb`](https://github.com/kazzix14/mangrove/tree/main/spec).

## Features
Most features are not implemented.

- [x] Option Type (Partially Implemented)
  - [x] Auto propagation like Rust's `?` (formerly `try!`)
- [x] Result Type (Partially Implemented)
  - [x] Auto propagation like Rust's `?` (formerly `try!`)
- [ ] Builder type (Not implemented)
  - [ ] Auto Implementation
- [ ] TODO

## Installation

```
bundle add mangrove
```

## Usage

see [`spec/**/**_spec.rb`](https://github.com/kazzix14/mangrove/tree/main/spec).

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

# Including this Module into your class appends rescue clause into its methods. Results to `Option#unwrap!` and `Result#unwrap!` propagates to calling method like Ruet's `?` operator.
# https://doc.rust-lang.org/reference/expressions/operator-expr.html#the-question-mark-operator
include Mangrove::ControlFlow::Handler
```

## Commands
```
bundle exec tapioca init
bundle exec tapioca gems
bundle exec tapioca dsl
bundle exec tapioca check-shims
bundle exec tapioca init
bundle exec rspec -f d
bundle exec rubocop -DESP
bundle exec srb typecheck
bundle exec ordinare --check
bundle exec ruboclean
rake build
rake release
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kazzix14/mangrove.
