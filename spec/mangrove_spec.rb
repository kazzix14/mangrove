# typed: strict
# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mangrove do
  it "has a version number" do
    expect(Mangrove::VERSION).not_to be nil
  end

  context "[Practical Example]" do
    it "Transposes Array[Result[T, E]] into Result[Array[T], Array[E]]" do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class TransposeExample
        extend T::Sig

        include Mangrove::ControlFlow::Handler

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
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      expect(TransposeExample.new.divide_arguments_by_3([3, 4, 5])).to eq Mangrove::Result::Err.new(["number 4 is not divisible by 3", "number 5 is not divisible by 3"])
      expect(TransposeExample.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    end

    it "Automatically propagates result" do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class PropagationExample
        extend T::Sig

        include Mangrove::ControlFlow::Handler

        sig { params(numbers: T::Enumerable[Integer]).returns(Mangrove::Result[T::Array[Integer], String]) }
        def divide_arguments_by_3(numbers)
          divided_numbers = numbers
            .map { |number|
              if number % 3 == 0
                Mangrove::Result::Ok.new(number / 3)
              else
                Mangrove::Result::Err.new("number #{number} is not divisible by 3")
              end
            }
            .map(&:unwrap!)

          Mangrove::Result::Ok.new(divided_numbers)
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      expect(PropagationExample.new.divide_arguments_by_3([3, 4, 5])).to eq Mangrove::Result::Err.new("number 4 is not divisible by 3")
      expect(PropagationExample.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    end
  end
end
