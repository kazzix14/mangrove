# typed: strict
# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mangrove do
  it "has a version number" do
    expect(Mangrove::VERSION).not_to be nil
  end

  context do
    it do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class MyClass
        extend T::Sig

        include Mangrove::ControlFlow::Handler

        sig { params(numbers: T::Enumerable[Integer]).returns(Mangrove::Result[T::Array[Integer], String]) }
        def divide_arguments_by_3(numbers)
          divided_nubmers = numbers
                            .map do |number|
            if number % 3 == 0
              Mangrove::Result::Ok.new(number / 3)
            else
              Mangrove::Result::Err.new("number #{number} is not divisible by 3")
            end
          end
                            .map(&:unwrap!)

          Mangrove::Result::Ok.new(divided_nubmers)
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      expect(MyClass.new.divide_arguments_by_3([3, 4, 6])).to eq Mangrove::Result::Err.new("number 4 is not divisible by 3")
      expect(MyClass.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    end
  end
end
