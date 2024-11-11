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

        sig { params(numbers: T::Enumerable[Integer]).returns(Mangrove::Result[T::Enumerable[Integer], String]) }
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
    end

    it "Propagates result" do
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

    it "Can express Service Return values more precisely" do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      module TypeSafeStringExt
        extend T::Sig
        extend T::Helpers

        include Kernel
        abstract!

        sig { returns(Mangrove::Result[Integer, ArgumentError]) }
        def safe_to_i
          T.bind(self, String)

          Mangrove::Result.ok_wt(Integer(self), ArgumentError)
        rescue ArgumentError => e
          Mangrove::Result.err_wt(Integer, e)
        end
      end

      class ::String
        include TypeSafeStringExt
      end

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
              MyServiceError::Other.new(MyAppError::Other.new(e)).as_my_service_error
            }.and_then_wt(String) { |num|
              if num < 1
                Mangrove::Result.err_wt(String, MyServiceError::E1.new(MyAppError::E1.new("num < 1")).as_my_service_error)
              elsif num < 3
                Mangrove::Result
                  .ok_wt(num, String)
                  .and_then_wt(String) { |n|
                    if n < 2
                      Mangrove::Result.ok_wt("`#{n}` < 2", String)
                    else
                      Mangrove::Result.err_wt(String, "not `#{n}` < 2")
                    end
                  }
                  .map_err_wt(MyServiceError::E1) { |e|
                    MyServiceError::E1.new(MyAppError::E1.new("mapping to E1 #{e}")).as_my_service_error
                  }
                  .map_ok { |str|
                    "{my_key: #{str}}"
                  }
                  .map_ok(&:to_s)
              else
                Mangrove::Result.err_wt(String, MyServiceError::E2.new(MyAppError::E2.new).as_my_service_error)
              end
            }
        end

        module MyServiceError
          extend T::Sig
          extend T::Helpers

          abstract!
          sealed!

          sig { abstract.returns(MyAppError) }
          def inner; end

          sig(:final) { returns(MyServiceError) }
          def as_my_service_error
            T.let(self, MyServiceError)
          end

          class E1
            extend T::Sig

            include MyServiceError

            sig { params(inner: MyAppError::E1).void }
            def initialize(inner)
              @inner = inner
            end

            sig { override.returns(MyAppError::E1) }
            attr_reader :inner
          end

          class E2
            extend T::Sig

            include MyServiceError

            sig { params(inner: MyAppError::E2).void }
            def initialize(inner)
              @inner = inner
            end

            sig { override.returns(MyAppError::E2) }
            attr_reader :inner
          end

          class Other
            extend T::Sig

            include MyServiceError

            sig { params(inner: MyAppError::Other).void }
            def initialize(inner)
              @inner = inner
            end

            sig { override.returns(MyAppError::Other) }
            attr_reader :inner
          end
        end
      end

      class MyAppError
        extend T::Sig
        extend T::Helpers

        abstract!

        sig { abstract.returns(String) }
        def msg; end

        class Other < MyAppError
          extend T::Sig

          sig { params(inner: Exception).void }
          def initialize(inner)
            @inner = inner
          end

          sig { override.returns(String) }
          def msg
            @inner.to_s
          end
        end

        class E1 < MyAppError
          extend T::Sig

          sig { params(msg: String).void }
          def initialize(msg)
            @msg = msg
          end

          sig { override.returns(String) }
          attr_reader :msg
        end

        class E2 < MyAppError
          extend T::Sig

          sig { override.returns(String) }
          def msg = "e2"
        end

        class E3 < MyAppError
          extend T::Sig

          sig { override.returns(String) }
          def msg = "e3"
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      expect(MyController.new.create("0").force_encoding("UTF-8")).to eq "e1: num < 1"
      expect(MyController.new.create("1").force_encoding("UTF-8")).to eq "{my_key: `1` < 2}"
      expect(MyController.new.create("2").force_encoding("UTF-8")).to eq "e1: mapping to E1 not `2` < 2"
      expect(MyController.new.create("3").force_encoding("UTF-8")).to eq "e2: e2"
      expect(MyController.new.create("invalid").force_encoding("UTF-8")).to eq "other: invalid value for Integer(): \"invalid\""
    end
  end
end
