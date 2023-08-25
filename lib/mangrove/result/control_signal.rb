# typed: strict
# frozen_string_literal: true

require "mangrove/control_flow/control_signal"

module Mangrove
  module Result
    class ControlSignal < StandardError
      extend T::Sig

      include Mangrove::ControlFlow::ControlSignal

      sig { params(inner_value: T.untyped).void }
      def initialize(inner_value)
        @inner_value = inner_value
        super
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

      sig { override.returns(T.untyped) }
      attr_reader :inner_value
    end
  end
end
