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
          # inner_type.newにする？
          Mangrove::Result::Err[T.untyped, e.inner_type].new(e.inner_value)
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
        rescue ::Mangrove::ControlFlow::ControlSignal => e
          Mangrove::Result::Err.new(e.inner_value)
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      expect(PropagationExample.new.divide_arguments_by_3([3, 4, 5])).to eq Mangrove::Result::Err.new("number 4 is not divisible by 3")
      expect(PropagationExample.new.divide_arguments_by_3([3, 6, 9])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    end
  end

  context "Test" do
    class MyTest
      extend T::Sig

      sig { void }
      def create
        MyService.new.execute
      end
    end

    class MyService
      extend T::Sig
      extend T::Generic

      include Kernel

      E = type_member {{upper: MyServiceError}}

      sig { returns(Mangrove::Result[String, MyServiceError])}
      def execute
        if rand() < 0.5
          err = Mangrove::Result.err(String, MyServiceError::E1.new(MyError::E1.new))
          return err
        elsif rand() < 0.5
          err = Mangrove::Result.err(String, MyServiceError::E2.new(MyError::E2.new))
          return err
          #return Mangrove::Result::Err[String, MyError::E2].new(MyError::E2.new)
        else
          err = Mangrove::Result.err(String, MyServiceError::E1.new(MyError::E1.new))
          return err
          #return Mangrove::Result::Err[String, MyError::E3].new(MyError::E3.new)
        end
      end

      module MyServiceError
        extend T::Sig
        extend T::Helpers

        interface!
        sealed!

        sig { abstract.returns(MyError) }
        def inner; end

        class E1
          extend T::Sig

          include MyServiceError

          sig { params(inner: MyError::E1).void }
          def initialize(inner)
            @inner = inner
          end

          sig { override.returns(MyError::E1) }
          def inner = @inner
        end

        class E2
          extend T::Sig

          include MyServiceError

          sig { params(inner: MyError::E2).void }
          def initialize(inner)
            @inner = inner
          end

          sig { override.returns(MyError::E2) }
          def inner = @inner
        end
      end
    end

    class MyError
      class E1 < MyError
        extend T::Sig

        sig { returns(String) }
        def msg = "e1"
      end

      class E2 < MyError
        extend T::Sig

        sig { returns(String) }
        def msg = "e2"
      end

      class E3 < MyError
        extend T::Sig

        sig { returns(String) }
        def msg = "e2"
      end
    end
  end
end
