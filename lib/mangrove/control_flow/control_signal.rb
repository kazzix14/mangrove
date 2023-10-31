# typed: strict
# frozen_string_literal: true

module Mangrove
  module ControlFlow
    module ControlSignal
      extend T::Sig
      extend T::Helpers
      extend T::Generic

      interface!

      InnerType = type_member

      sig { abstract.returns(InnerType) }
      def inner_value; end

      sig { abstract.returns(Module) }
      def inner_type; end
    end
  end
end
