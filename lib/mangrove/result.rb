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
    InOkType = type_member(:in)
    ErrType = type_member(:out)
    InErrType = type_member(:in)

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

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, InOkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
    def map(&block); end

    sig { abstract.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T.type_parameter(:NewOkType), _t_new_err: T.type_parameter(:NewErrType), block: T.proc.params(this: Result[OkType, InOkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
    def map_wt(_t_new_ok, _t_new_err, &block); end

    sig { abstract.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
    def map_ok(&block); end

    sig { abstract.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
    def map_ok_wt(_t_new_ok, &block); end

    sig { abstract.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
    def map_err(&block); end

    sig { abstract.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
    def map_err_wt(_t_new_err, &block); end

    # ErrTypeにInを入れたい（type parameterは狭くしたいので）
    sig { abstract.type_parameters(:NewOkType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), InErrType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
    def and(other); end

    sig { abstract.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), InErrType, ErrType])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
    def and_then(&block); end

    sig { abstract.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), InErrType, ErrType])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
    def and_then_wt(_t_new_ok, &block); end

    sig { abstract.params(other: Result[InOkType, OkType, InErrType, ErrType]).returns(Result[OkType, InOkType, ErrType, InErrType]) }
    def or(other); end

    #sig { abstract.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
    #def or_else(&block); end

    #sig { abstract.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
    #def or_else_wt(_t_new_err, &block); end

    class << self
      extend T::Sig
      extend T::Generic

      OkType = type_member(:out)
      ErrType = type_member(:out)

      sig { type_parameters(:T, :E).params(results: T::Enumerable[Result[T.type_parameter(:T), T.type_parameter(:T), T.type_parameter(:E), T.type_parameter(:E)]]).returns(Result[T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:E)], T::Enumerable[T.type_parameter(:E)]]) }
      def from_results(results)
        errs = results.filter(&:err?)

        if errs.empty?
          # This is safe as errs is empty.
          Result::Ok[T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:E)], T::Enumerable[T.type_parameter(:E)]].new(results.map { |r| T.cast(r, Result::Ok[T.type_parameter(:T), T::Enumerable[T.type_parameter(:T)], T.type_parameter(:E), T.type_parameter(:E)]).ok_inner })
        else
          # This is safe as errs is results where err? is true
          Result::Err[T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:T)], T::Enumerable[T.type_parameter(:E)], T::Enumerable[T.type_parameter(:E)]].new(errs.map { |r| T.cast(r, Result::Err[T.type_parameter(:T), T::Enumerable[T.type_parameter(:T)], T.type_parameter(:E), T.type_parameter(:E)]).err_inner })
        end
      end

      sig { type_parameters(:OkType, :ErrType).params(inner: T.type_parameter(:OkType), _t_err: T::Class[T.type_parameter(:ErrType)]).returns(Result::Ok[T.type_parameter(:OkType), T.type_parameter(:OkType), T.type_parameter(:ErrType), T.type_parameter(:ErrType)]) }
      def ok(inner, _t_err)
        Result::Ok[T.type_parameter(:OkType), T.type_parameter(:OkType), T.type_parameter(:ErrType), T.type_parameter(:ErrType)].new(inner)
      end

      sig { type_parameters(:OkType, :ErrType).params(_t_ok: T::Class[T.type_parameter(:OkType)], inner: T.type_parameter(:ErrType)).returns(Result::Err[T.type_parameter(:OkType), T.type_parameter(:OkType), T.type_parameter(:ErrType), T.type_parameter(:ErrType)]) }
      def err(_t_ok, inner)
        Result::Err[T.type_parameter(:OkType), T.type_parameter(:OkType), T.type_parameter(:ErrType), T.type_parameter(:ErrType)].new(inner)
      end
    end

    class Ok
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Result

      OkType = type_member(:out)
      InOkType = type_member(:in)
      ErrType = type_member(:out)
      InErrType = type_member(:in)

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

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, InOkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map(&block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T.type_parameter(:NewOkType), _t_new_err: T.type_parameter(:NewErrType), block: T.proc.params(this: Result[OkType, InOkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_wt(_t_new_ok, _t_new_err, &block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
      def map_ok(&block)
        Result::Ok[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType].new(block.call(@inner))
      end

      # Because sorbet deduct types from return values well. This method takes a type of new inner values.
      sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
      def map_ok_wt(_t_new_ok, &block)
        Result::Ok[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType].new(block.call(@inner))
      end

      sig { override.type_parameters(:NewErrType).params(_block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_err(&_block)
        T.cast(self, Result::Ok[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])
      end

      # Because sorbet deduct types from return values well. This method takes a type of new inner values.
      sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], _block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_err_wt(_t_new_err, &_block)
        T.cast(self, Result::Ok[OkType, InOkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])
      end

      sig { override.type_parameters(:NewOkType).params(other: Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), InErrType, ErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), ErrType, InErrType]) }
      def and(other)
        other
        #T.cast(other, Result[T.type_parameter(:NewOkType), T.type_parameter(:NewOkType), InErrType, ErrType])
        # other
      end

      #sig { override.type_parameters(:NewOkType).params(block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      #def and_then(&block)
      #  block.call(@inner)
      #end

      #sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      #def and_then_wt(_t_new_ok, &block)
      #  block.call(@inner)
      #end

      #sig { override.params(_other: Result[OkType, ErrType]).returns(Result[OkType, ErrType]) }
      #def or(_other)
      #  self
      #end

      #sig { override.type_parameters(:NewErrType).params(_block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      #def or_else(&_block)
      #  T.cast(self, Result::Ok[OkType, T.type_parameter(:NewErrType)])
      #end

      #sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], _block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      #def or_else_wt(_t_new_err, &_block)
      #  T.cast(self, Result::Ok[OkType, T.type_parameter(:NewErrType)])
      #end

      sig { returns(String) }
      def to_s
        "#{super}: inner=`#{@inner}`"
      end

      sig { params(inner: OkType).void }
      def initialize(inner)
        @inner = inner
      end

      private :initialize
    end

    class Err
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Result

      OkType = type_member(:out)
      InOkType = type_member(:in)
      ErrType = type_member(:out)
      InErrType = type_member(:in)

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

      sig { override.type_parameters(:NewOkType, :NewErrType).params(block: T.proc.params(this: Result[OkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map(&block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType, :NewErrType).params(_t_new_ok: T.type_parameter(:NewOkType), _t_new_err: T.type_parameter(:NewErrType), block: T.proc.params(this: Result[OkType, ErrType, InErrType]).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)])).returns(Result[T.type_parameter(:NewOkType), T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_wt(_t_new_ok, _t_new_err, &block)
        block.call(self)
      end

      sig { override.type_parameters(:NewOkType).params(_block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType, InErrType]) }
      def map_ok(&_block)
        T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType, InErrType])
      end

      # Because sorbet deduct types from return values well. This method takes a type of new inner values.
      sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _block: T.proc.params(this: OkType).returns(T.type_parameter(:NewOkType))).returns(Result[T.type_parameter(:NewOkType), ErrType, InErrType]) }
      def map_ok_wt(_t_new_ok, &_block)
        T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType, InErrType])
      end

      sig { override.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_err(&block)
        Result::Err[OkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)].new(block.call(@inner))
      end

      sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(T.type_parameter(:NewErrType))).returns(Result[OkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)]) }
      def map_err_wt(_t_new_err, &block)
        Result::Err[OkType, T.type_parameter(:NewErrType), T.type_parameter(:NewErrType)].new(block.call(@inner))
      end

      #sig { override.type_parameters(:NewOkType).params(_other: Result[T.type_parameter(:NewOkType), ErrType]).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      #def and(_other)
      #  T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType])
      #end

      #sig { override.type_parameters(:NewOkType).params(_block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      #def and_then(&_block)
      #  T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType])
      #end

      #sig { override.type_parameters(:NewOkType).params(_t_new_ok: T::Class[T.type_parameter(:NewOkType)], _block: T.proc.params(this: OkType).returns(Result[T.type_parameter(:NewOkType), ErrType])).returns(Result[T.type_parameter(:NewOkType), ErrType]) }
      #def and_then_wt(_t_new_ok, &_block)
      #  T.cast(self, Result::Err[T.type_parameter(:NewOkType), ErrType])
      #end

      #sig { override.params(other: Result[OkType, ErrType]).returns(Result[OkType, ErrType]) }
      #def or(other)
      #  other
      #end

      #sig { override.type_parameters(:NewErrType).params(block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      #def or_else(&block)
      #  block.call(@inner)
      #end

      #sig { override.type_parameters(:NewErrType).params(_t_new_err: T::Class[T.type_parameter(:NewErrType)], block: T.proc.params(this: ErrType).returns(Result[OkType, T.type_parameter(:NewErrType)])).returns(Result[OkType, T.type_parameter(:NewErrType)]) }
      #def or_else_wt(_t_new_err, &block)
      #  block.call(@inner)
      #end

      sig { returns(String) }
      def to_s
        "#{super}: inner=`#{@inner}`"
      end
    end
  end
end
