# typed: strict
# frozen_string_literal: true

require_relative "result/control_signal"

module Mangrove
  # Result is a type that represents either success (`Ok`) or failure (`Err`).
  module Result
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    include Kernel

    sealed!
    interface!

    OkType = type_member
    ErrType = type_member

    sig { abstract.params(other: BasicObject).returns(T::Boolean) }
    def ==(other); end

    sig { abstract.returns(T::Boolean) }
    def ok?; end

    sig { abstract.returns(T::Boolean) }
    def err?; end

    sig { abstract.returns(OkType) }
    def unwrap!; end

    sig { abstract.params(message: String).returns(OkType) }
    def expect!(message); end

    sig { abstract.params(block: T.proc.returns(T.untyped)).returns(OkType) }
    def expect_with!(&block); end

    sig { abstract.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
    def map_ok(&block); end

      sig { abstract.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
    def map_err(&block); end

    class << self
      extend T::Sig
      extend T::Generic

      OkType = type_member
      ErrType = type_member

      sig { params(results: T::Enumerable[Mangrove::Result[OkType, ErrType]]).returns(Result[OkType, ErrType]) }
      def from_results(results)
        errs = results.filter(&:err?)

        if errs.empty?
          # This is safe as errs is empty.
          Result::Ok.new(results.map { |r| T.cast(r, Result::Ok[OkType, ErrType]).ok_inner })
        else
          # This is safe as errs is results where err? is true
          Result::Err.new(errs.map { |r| T.cast(r, Result::Err[OkType, ErrType]).err_inner })
        end
      end
    end

    class Ok
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Result

      OkType = type_member
      ErrType = type_member

      sig { params(inner: OkType).void }
      def initialize(inner)
        @inner = inner
      end

      sig { override.params(other: BasicObject).returns(T::Boolean) }
      def ==(other)
        case other
        when Result::Ok
          other.instance_variable_get(:@inner) == @inner
        when Result::Err
          false
        else
          false
        end
      end

      sig { returns(OkType) }
      def ok_inner
        @inner
      end

      sig { override.returns(OkType) }
      def unwrap!
        @inner
      end

      sig { override.params(_message: String).returns(OkType) }
      def expect!(_message)
        @inner
      end

      sig { override.params(_block: T.proc.returns(T.untyped)).returns(OkType) }
      def expect_with!(&_block)
        @inner
      end

      sig { override.returns(T::Boolean) }
      def ok? = true

      sig { override.returns(T::Boolean) }
      def err? = false

      sig { override.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok(&block)
        block.call(@inner)
      end

      sig { override.type_parameters(:NewErrType).params(_block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err(&_block)
        T.cast(self, Result::Ok[OkType, T.type_parameter(:NewErrType)])
      end

      sig { returns(String) }
      def to_s
        "#{super}: inner=`#{@inner}`"
      end
    end

    class Err
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Result

      OkType = type_member
      ErrType = type_member

      sig { params(inner: ErrType).void }
      def initialize(inner)
        @inner = inner
      end

      sig { override.params(other: BasicObject).returns(T::Boolean) }
      def ==(other)
        case other
        when Result::Ok
          false
        when Result::Err
          other.instance_variable_get(:@inner) == @inner
        else
          false
        end
      end

      sig { returns(ErrType) }
      def err_inner
        @inner
      end

      sig { override.returns(OkType) }
      def unwrap!
        raise Result::ControlSignal, @inner
      end

      sig { override.params(message: String).returns(OkType) }
      def expect!(message)
        raise Result::ControlSignal, message
      end

      sig { override.params(block: T.proc.returns(T.untyped)).returns(OkType) }
      def expect_with!(&block)
        raise Result::ControlSignal, block.call
      end

      sig { override.returns(T::Boolean) }
      def ok? = false

      sig { override.returns(T::Boolean) }
      def err? = true

      sig { override.type_parameters(:NewOkType).params(_block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok(&_block)
        T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType])
      end

      sig { override.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err(&block)
        block.call(@inner)
      end

      sig { returns(String) }
      def to_s
        "#{super}: inner=`#{@inner}`"
      end
    end
  end
end
