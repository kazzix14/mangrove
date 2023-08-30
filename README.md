# Mangrove
Mangrove provides type utility to use with Sorbet.

You can do something like this using this gem.

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

Other examples are available at `spec/**/**_spec.rb`.

## Features
Most features are not implemented.

- [x] Option Type (Partially Implemented)
  - [x] Auto propagation like Rust's `?` (formerly `try!`)
- [x] Result Type (Partially Implemented)
  - [x] Auto propagation like Rust's `?` (formerly `try!`)
- [ ] Builder type (Not implemented)
  - [ ] Auto Implementation
- [ ] TODO

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/mangrove`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mangrove.
