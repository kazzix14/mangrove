# typed: strict
# frozen_string_literal: true

module Mangrove
  module ControlFlow
    module ControlSignal
      extend T::Sig
      extend T::Helpers

      interface!

      sig { abstract.returns(T.untyped) }
      def inner_value; end
    end
  end
end
