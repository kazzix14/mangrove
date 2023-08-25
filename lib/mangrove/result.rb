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

    # Mangrove::Result::Ok
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
      def unwrap
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

      sig { override.returns(T::Boolean) }
      def ok? = true

      sig { override.returns(T::Boolean) }
      def err? = false

      sig { override.params(block: T.proc.params(this: OkType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
      def map_ok(&block)
        block.call(@inner)
      end

      sig { override.params(_block: T.proc.params(this: ErrType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
      def map_err(&_block)
        self
      end
    end

    # Mangrove::Result::Err
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

      sig { override.returns(OkType) }
      def unwrap!
        raise Result::ControlSignal, Result::Err.new("called `Result#unwrap!` on an `Err` value: #{self}")
      end

      sig { override.params(message: String).returns(OkType) }
      def expect!(message)
        raise Result::ControlSignal, Result::Err.new(message)
      end

      sig { override.returns(T::Boolean) }
      def ok? = false

      sig { override.returns(T::Boolean) }
      def err? = true

      sig do
        override.params(_block: T.proc.params(this: OkType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType])
      end
      def map_ok(&_block)
        self
      end

      sig do
        override.params(block: T.proc.params(this: ErrType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType])
      end
      def map_err(&block)
        block.call(@inner)
      end
    end

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

    sig do
      abstract.params(block: T.proc.params(this: OkType).returns(Result[OkType,
                                                                        ErrType])).returns(Result[OkType, ErrType])
    end
    def map_ok(&block); end

    sig do
      abstract.params(block: T.proc.params(this: ErrType).returns(Result[OkType,
                                                                         ErrType])).returns(Result[OkType, ErrType])
    end
    def map_err(&block); end
  end
end
