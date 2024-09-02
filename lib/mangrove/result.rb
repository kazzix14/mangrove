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

    OkType = type_member(:out)
    ErrType = type_member(:out)

    sig { abstract.params(other: BasicObject).returns(T::Boolean) }
    def ==(other); end

    # @deprecated Use #is_a?(Result::Ok) instead to enable Sorbet to define types statically.
    #   This method will be removed in future versions.
    sig { abstract.returns(T::Boolean) }
    def ok?; end

    # @deprecated Use #is_a?(Result::Err) instead to enable Sorbet to define types statically.
    sig { abstract.returns(T::Boolean) }
    def err?; end

    sig { abstract.returns(OkType) }
    def unwrap!; end

    sig { abstract.params(block: T.proc.params(err: ErrType).returns(Exception)).returns(OkType) }
    def unwrap_or_raise_with!(&block); end

    sig { abstract.params(exception: Exception).returns(OkType) }
    def unwrap_or_raise!(exception); end

    sig { abstract.returns(OkType) }
    def unwrap_or_raise_inner!; end

    sig { abstract.params(message: String).returns(OkType) }
    def expect!(message); end

    sig { abstract.type_parameters(:E).params(block: T.proc.params(err: ErrType).returns(T.type_parameter(:E))).returns(OkType) }
    def expect_with!(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
    def map(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
    def map_wt(_t_new_ok, _t_new_err, &block); end

    sig { abstract.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
    def map_ok(&block); end

    sig { abstract.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
    def map_ok_wt(_t_new_ok, &block); end

    sig { abstract.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
    def map_err(&block); end

    sig { abstract.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
    def map_err_wt(_t_new_err, &block); end

    sig { abstract.params(block: T.proc.params(this: OkType).void).returns(Result[OkType, ErrType]) }
    def tap_ok(&block); end

    sig { abstract.params(block: T.proc.params(this: ErrType).void).returns(Result[OkType, ErrType]) }
    def tap_err(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(T.any(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), ErrType])) }
    def and(other); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(T.any(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), ErrType])) }
    def and_then(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(T.any(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), ErrType])) }
    def and_then_wt(_t_new_ok, &block); end

    sig {
      abstract
        .type_parameters(:NewErrType)
        .params(
          new_err_inner: T.type_parameter(:NewErrType),
          condition: T.proc.params(inner: OkType).returns(T::Boolean)
        )
        .returns(
          T.any(Result[OkType, T.type_parameter(:NewErrType)], Result[OkType, ErrType])
        )
    }
    def and_err_if(new_err_inner, &condition); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(T.any(Result[OkType, T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])) }
    def or(other); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(T.any(Result[OkType, T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])) }
    def or_else(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(T.any(Result[OkType, T.type_parameter(:NewErrType)], Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])) }
    def or_else_wt(_t_new_err, &block); end

    sig {
      abstract
        .type_parameters(:NewOkType)
        .params(
          new_ok_inner: T.type_parameter(:NewOkType),
          condition: T.proc.params(inner: ErrType).returns(T::Boolean)
        )
        .returns(
          T.any(Result[T.type_parameter(:NewOkType), ErrType], Result[OkType, ErrType])
        )
    }
    def or_ok_if(new_ok_inner, &condition); end

    class << self
      extend T::Sig
      extend T::Generic

      OkType = type_member
      ErrType = type_member

      sig { type_parameters(:T, :E).params(results: T::Enumerable[Result[T.type_parameter(:T), T.type_parameter(:E)]]).returns(Result[T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:E)]]) }
      def from_results(results)
        errs = results.filter(&:err?)

        if errs.empty?
          # This is safe as errs is empty.
          Result::Ok[T::Enumerable[T.type_parameter(:T)]].new(results.map { |r| T.cast(r, Result::Ok[T.type_parameter(:T)]).ok_inner })
        else
          # This is safe as errs is results where err? is true
          Result::Err[T::Enumerable[T.type_parameter(:E)]].new(errs.map { |r| T.cast(r, Result::Err[T.type_parameter(:E)]).err_inner })
        end
      end

      sig { type_parameters(:OkType).params(inner: T.type_parameter(:OkType)).returns(Result::Ok[T.type_parameter(:OkType)]) }
      def ok(inner)
        Result::Ok[T.type_parameter(:OkType)].new(inner)
      end

      # @deprecated
      sig { type_parameters(:OkType, :ErrType).params(inner: T.type_parameter(:OkType), _t_err: T::Class[T.type_parameter(:ErrType)]).returns(Result::Ok[T.type_parameter(:OkType)]) }
      def ok_wt(inner, _t_err)
        Result::Ok[T.type_parameter(:OkType)].new(inner)
      end

      sig { type_parameters(:ErrType).params(inner: T.type_parameter(:ErrType)).returns(Result::Err[T.type_parameter(:ErrType)]) }
      def err(inner)
        Result::Err[T.type_parameter(:ErrType)].new(inner)
      end

      # @deprecated
      sig { type_parameters(:OkType, :ErrType).params(_t_ok: T::Class[T.type_parameter(:OkType)], inner: T.type_parameter(:ErrType)).returns(Result::Err[T.type_parameter(:ErrType)]) }
      def err_wt(_t_ok, inner)
        Result::Err[T.type_parameter(:ErrType)].new(inner)
      end
    end

    class Ok
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Result

      OkType = type_member
      ErrType = type_member { { fixed: T.noreturn } }

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
        else # rubocop:disable Lint/DuplicateBranch
          # Because == is defined on BasicObject, we can't be sure that `other` is an Option
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

      sig { override.params(_exception: Exception).returns(OkType) }
      def unwrap_or_raise!(_exception)
        @inner
      end

      sig { override.params(_block: T.proc.params(err: ErrType).returns(Exception)).returns(OkType) }
      def unwrap_or_raise_with!(&_block)
        @inner
      end

      sig { override.returns(OkType) }
      def unwrap_or_raise_inner!
        @inner
      end

      sig { override.params(_message: String).returns(OkType) }
      def expect!(_message)
        @inner
      end

      sig { override.type_parameters(:E).params(_block: T.proc.params(err: ErrType).returns(T.type_parameter(:E))).returns(OkType) }
      def expect_with!(&_block)
        @inner
      end

      # @deprecated Use #is_a?(Result::Ok) instead to enable Sorbet to define types statically.
      sig { override.returns(T::Boolean) }
      def ok? = true

      # @deprecated Use #is_a?(Result::Err) instead to enable Sorbet to define types statically.
      sig { override.returns(T::Boolean) }
      def err? = false

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def map(&block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def map_wt(_t_new_ok, _t_new_err, &block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok(&block)
        Result::Ok[T.type_parameter(:NewOkType)].new(block.call(@inner))
      end

      # Because sorbet does not deduct types from return values well. This method takes a type of new inner values.
      sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok_wt(_t_new_ok, &block)
        Result::Ok[T.type_parameter(:NewOkType)].new(block.call(@inner))
      end

      sig { override.type_parameters(:NewErrType).params(_block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err(&_block)
        self
      end

      # Because sorbet does not deduct types from return values well. This method takes a type of new inner values.
      sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], _block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err_wt(_t_new_err, &_block)
        self
      end

      sig { override.params(block: T.proc.params(this: OkType).void).returns(Result[OkType, ErrType]) }
      def tap_ok(&block)
        block.call(@inner)
        self
      end

      sig { override.params(_block: T.proc.params(this: ErrType).void).returns(Result[OkType, ErrType]) }
      def tap_err(&_block)
        self
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def and(other)
        other
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def and_then(&block)
        block.call(@inner)
      end

      # @deprecated
      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def and_then_wt(_t_new_ok, &block)
        block.call(@inner)
      end

      sig {
        override
          .type_parameters(:NewErrType)
          .params(
            new_err_inner: T.type_parameter(:NewErrType),
            condition: T.proc.params(inner: OkType).returns(T::Boolean)
          )
          .returns(
            Result[OkType, T.type_parameter(:NewErrType)]
          )
      }
      def and_err_if(new_err_inner, &condition)
        if condition.call(@inner)
          Result::Err[T.type_parameter(:NewErrType)].new(new_err_inner)
        else
          self
        end
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def or(_other)
        self
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def or_else(&_block)
        self
      end

      # @deprecated
      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], _block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def or_else_wt(_t_new_err, &_block)
        self
      end

      sig {
        override
          .type_parameters(:NewOkType)
          .params(
            _new_ok_inner: T.type_parameter(:NewOkType),
            _condition: T.proc.params(inner: ErrType).returns(T::Boolean)
          )
          .returns(
            Result[OkType, ErrType]
          )
      }
      def or_ok_if(_new_ok_inner, &_condition)
        self
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

      OkType = type_member { { fixed: T.noreturn } }
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
        else # rubocop:disable Lint/DuplicateBranch
          # Because == is defined on BasicObject, we can't be sure that `other` is an Option
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

      sig { override.params(exception: Exception).returns(OkType) }
      def unwrap_or_raise!(exception)
        raise exception
      end

      sig { override.params(block: T.proc.params(err: ErrType).returns(Exception)).returns(OkType) }
      def unwrap_or_raise_with!(&block)
        raise block.call(@inner)
      end

      sig { override.returns(OkType) }
      def unwrap_or_raise_inner!
        raise T.unsafe(@inner)
      end

      sig { override.params(message: String).returns(OkType) }
      def expect!(message)
        raise Result::ControlSignal, message
      end

      sig { override.type_parameters(:E).params(block: T.proc.params(err: ErrType).returns(T.type_parameter(:E))).returns(OkType) }
      def expect_with!(&block)
        raise Result::ControlSignal, block.call(@inner)
      end

      # @deprecated Use #is_a?(Result::Ok) instead to enable Sorbet to define types statically.
      sig { override.returns(T::Boolean) }
      def ok? = false

      # @deprecated Use #is_a?(Result::Err) instead to enable Sorbet to define types statically.
      sig { override.returns(T::Boolean) }
      def err? = true

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def map(&block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: Result[OkType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def map_wt(_t_new_ok, _t_new_err, &block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType).params(_block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok(&_block)
        self
      end

      sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def map_ok_wt(_t_new_ok, &_block)
        self
      end

      sig { override.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err(&block)
        Result::Err[T.type_parameter(:NewErrType)].new(block.call(@inner))
      end

      sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      def map_err_wt(_t_new_err, &block)
        Result::Err[T.type_parameter(:NewErrType)].new(block.call(@inner))
      end

      sig { override.params(_block: T.proc.params(this: OkType).void).returns(Result[OkType, ErrType]) }
      def tap_ok(&_block)
        self
      end

      sig { override.params(block: T.proc.params(this: ErrType).void).returns(Result[OkType, ErrType]) }
      def tap_err(&block)
        block.call(@inner)
        self
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def and(_other)
        self
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def and_then(&_block)
        self
      end

      # @deprecated
      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      def and_then_wt(_t_new_ok, &_block)
        self
      end

      sig {
        override
          .type_parameters(:NewErrType)
          .params(
            _new_err_inner: T.type_parameter(:NewErrType),
            _condition: T.proc.params(inner: OkType).returns(T::Boolean)
          )
          .returns(
            Result[OkType, ErrType]
          )
      }
      def and_err_if(_new_err_inner, &_condition)
        self
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def or(other)
        other
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def or_else(&block)
        block.call(@inner)
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType)]) }
      def or_else_wt(_t_new_err, &block)
        block.call(@inner)
      end

      sig {
        override
          .type_parameters(:NewOkType)
          .params(
            new_ok_inner: T.type_parameter(:NewOkType),
            condition: T.proc.params(inner: ErrType).returns(T::Boolean)
          )
          .returns(
            Result[T.type_parameter(:NewOkType), ErrType]
          )
      }
      def or_ok_if(new_ok_inner, &condition)
        if condition.call(@inner)
          Result::Ok[T.type_parameter(:NewOkType)].new(new_ok_inner)
        else
          self
        end
      end

      sig { returns(String) }
      def to_s
        "#{super}: inner=`#{@inner}`"
      end
    end
  end
end
