# typed: strict
# frozen_string_literal: true

module Mangrove
  # Control Flow
  module ControlFlow
    # Signal
    module Signal
      extend T::Sig
      extend T::Helpers

      interface!

      sig { abstract.returns(T.untyped) }
      def inner_value; end
    end
  end
end
