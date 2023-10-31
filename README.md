# Mangrove
Mangrove provides type utility to use with Sorbet.
use `rubocop-mangrove` to statically check rescuing ControlSignal is done

You can do something like this with the gem.
```ruby
class TransposeExample
  extend T::Sig

  sig { params(numbers: T::Enumerable[Integer]).returns(Mangrove::Result[T::Array[Integer], String]) }
  def divide_arguments_by_3(numbers)
    Mangrove::Result.from_results(numbers
      .map { |number|
        if number % 3 == 0
          Mangrove::Result::Ok.new(number / 3)
        else
          Mangrove::Result::Err.new("number #{number} is not divisible by 3")
        end
      })
  rescue ::Mangrove::ControlFlow::ControlSignal => e
    Mangrove::Result::Err.new(e.inner_value)
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock

expect(TransposeExample.new.divide_arguments_by_3([3, 4, 5])).to eq Mangrove::Result::Err.new(["number 4 is not divisible by 3", "number 5 is not divisible by 3"])
expect(TransposeExample.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])

```

or like this.
```ruby
class MyController
  extend T::Sig

  sig { params(input: String).returns(String) }
  def create(input)
    result = MyService.new.execute(input)

    case result
    when Mangrove::Result::Ok
      result.ok_inner
    when Mangrove::Result::Err
      error = result.err_inner

      case error
      when MyService::MyServiceError::E1
        "e1: #{error.inner.msg}"
      when MyService::MyServiceError::E2
        "e2: #{error.inner.msg}"
      when MyService::MyServiceError::Other
        "other: #{error.inner.msg}"
      else T.absurd(error)
      end
    end
  end
end

class MyService
  extend T::Sig
  extend T::Generic

  include Kernel

  E = type_member { { upper: MyServiceError } }

  sig { params(input: String).returns(Mangrove::Result[String, MyServiceError]) }
  def execute(input)
    input
      .safe_to_i
      .map_err_wt(MyServiceError::Other) { |e|
        MyServiceError::Other.new(MyAppError::Other.new(e))
      }.and_then_wt(String) { |num|
        if num < 1
          Mangrove::Result.err(String, MyServiceError::E1.new(MyAppError::E1.new("num < 1")))
        elsif num < 3
          Mangrove::Result
            .ok(num, String)
            .and_then_wt(String) { |n|
              if n < 2
                Mangrove::Result.ok("`#{n}` < 2", String)
              else
                Mangrove::Result.err(String, "not `#{n}` < 2")
              end
            }
            .map_err_wt(MyServiceError::E1) { |e|
              MyServiceError::E1.new(MyAppError::E1.new("mapping to E1 #{e}"))
            }
            .map_ok { |str|
              {
                my_key: str
              }
            }
            .map_ok(&:to_s)
        else
          Mangrove::Result.err(String, MyServiceError::E2.new(MyAppError::E2.new))
        end
      }
  end
end
```

Other examples are available at [`spec/**/**_spec.rb`](https://github.com/kazzix14/mangrove/tree/main/spec).

## Features
Most features are not implemented.

- [x] Option Type
- [x] Result Type
- [ ] Builder Type Factory
  - [ ] Auto Implementation
- [ ] TODO

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

# Including this Module into your class appends rescue clause into its methods. Results to `Option#unwrap!` and `Result#unwrap!` propagates to calling method like Ruet's `?` operator.
# https://doc.rust-lang.org/reference/expressions/operator-expr.html#the-question-mark-operator
include Mangrove::ControlFlow::Handler
```

## Commands for Development
```
git config core.hooksPath hooks
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
bundle exec yardoc -o docs/ --plugin yard-sorbet
rake build
rake release
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kazzix14/mangrove.
