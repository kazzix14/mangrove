# typed: strict
# frozen_string_literal: true

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

      sig { returns(InnerType) }
      def unwrap
        @inner
      end

      sig { override.returns(InnerType) }
      def unwrap!
        @inner
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

      sig { override.returns(InnerType) }
      def unwrap!
        raise ControlFlow::Signal, Result::Err.new("called `Option#unwrap!` on an `None` value: #{self}")
      end
    end

    sig { abstract.returns(InnerType) }
    def unwrap!; end
  end
end
