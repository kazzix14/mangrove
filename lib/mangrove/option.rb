# typed: strict
# frozen_string_literal: true

require_relative "option/control_signal"
require_relative "result"

module Mangrove
  # Option is a type that represents either some value (`Some`) or no value (`None`).
  module Option
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    include Kernel

    sealed!
    interface!

    InnerType = type_member

    # Option::Some
    class Some
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Option

      InnerType = type_member

      sig { params(inner: InnerType).void }
      def initialize(inner)
        @inner = T.let(inner, InnerType)
      end

      sig { override.params(other: BasicObject).returns(T::Boolean) }
      def ==(other)
        case other
        when Option::Some
          other.instance_variable_get(:@inner) == @inner
        when Option::None
          false
        else
          # T.absurd(other)
          false
        end
      end

      sig { override.returns(InnerType) }
      def unwrap!
        @inner
      end

      sig { override.params(_message: String).returns(InnerType) }
      def expect!(_message)
        @inner
      end

      sig { override.params(block: T.proc.params(inner: InnerType).returns(Option[InnerType])).returns(Option[InnerType]) }
      def map_some(&block)
        block.call(@inner)
      end

      sig { override.params(_block: T.proc.returns(Option[InnerType])).returns(Option::Some[InnerType]) }
      def map_none(&_block)
        self
      end

      private

      sig { returns(InnerType) }
      attr_reader :inner
    end

    # Option::None
    class None
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Option

      InnerType = type_member

      sig { override.params(other: BasicObject).returns(T::Boolean) }
      def ==(other)
        case other
        when Option::Some
          false
        when Option::None
          true
        else
          false
          # T.absurd(other)
        end
      end

      sig { override.returns(InnerType) }
      def unwrap!
        raise Option::ControlSignal, Result::Err.new("called `Option#unwrap!` on an `None` value: #{self}")
      end

      sig { override.params(message: String).returns(InnerType) }
      def expect!(message)
        raise Option::ControlSignal, Result::Err.new(message)
      end

      sig { override.params(_block: T.proc.params(inner: InnerType).returns(Option[InnerType])).returns(Option::None[InnerType]) }
      def map_some(&_block)
        self
      end

      sig { override.params(block: T.proc.returns(Option[InnerType])).returns(Option[InnerType]) }
      def map_none(&block)
        block.call
      end
    end

    sig { abstract.params(other: BasicObject).returns(T::Boolean) }
    def ==(other); end

    sig { abstract.returns(InnerType) }
    def unwrap!; end

    sig { abstract.params(message: String).returns(InnerType) }
    def expect!(message); end

    sig { abstract.params(block: T.proc.params(inner: InnerType).returns(Option[InnerType])).returns(Option[InnerType]) }
    def map_some(&block); end

    sig { abstract.params(block: T.proc.returns(Option[InnerType])).returns(Option[InnerType]) }
    def map_none(&block); end
  end
end