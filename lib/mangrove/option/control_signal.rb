# typed: strict
# frozen_string_literal: true

require "mangrove/control_flow/control_signal"

module Mangrove
  module Option
    class ControlSignal < StandardError
      extend T::Sig
      extend T::Generic

      include Mangrove::ControlFlow::ControlSignal

      InnerType = type_member

      sig { params(inner_value: InnerType).void }
      def initialize(inner_value)
        @inner_value = inner_value
        @inner_type = T.let(T.class_of(inner_value), Module)
        super(T.let(inner_value, T.untyped))
      end

      sig { override.params(other: BasicObject).returns(T::Boolean) }
      def ==(other)
        case other
        when ControlSignal
          other.inner_value == inner_value
        else
          false
        end
      end

      sig { override.returns(InnerType) }
      attr_reader :inner_value

      sig { override.returns(Module) }
      attr_reader :inner_type
    end
  end
end
