# typed: strict
# frozen_string_literal: true

module Mangrove
  # Mangrove::ControlFlow
  module Result
    # Mangrove::Result::ControlFlow
    module ControlFlow
      # Mangrove::Result::ControlFlow::Signal
      class Signal
        extend T::Sig

        include Mangrove::ControlFlow::Signal

        sig { params(inner_value: T.untyped).void }
        def initialize(inner_value)
          @inner_value = inner_value
          super
        end

        sig { override.returns(T.untyped) }
        attr_reader :inner_value
      end
    end
  end
end
