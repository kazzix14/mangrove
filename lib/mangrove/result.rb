# typed: strict
# using `strict`. because `strong` does not allow to use #type_member

# frozen_string_literal: true


require_relative 'control_flow'

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

      sig { returns(OkType) }
      def unwrap
        @inner
      end

      sig { override.returns(OkType) }
      def unwrap!
        @inner
      end

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

      sig { override.returns(OkType) }
      def unwrap!
        raise Mangrove::Result::ControlFlow::Signal, Result::Err.new("called `Result#unwrap!` on an `Err` value: #{self}")
      end

      sig { override.params(_block: T.proc.params(this: OkType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
      def map_ok(&_block)
        self
      end

      sig { override.params(block: T.proc.params(this: ErrType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
      def map_err(&block)
        block.call(@inner)
      end
    end

    sig { abstract.returns(OkType) }
    def unwrap!; end

    sig { abstract.params(block: T.proc.params(this: OkType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
    def map_ok(&block); end

    sig { abstract.params(block: T.proc.params(this: ErrType).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
    def map_err(&block); end
  end
end

