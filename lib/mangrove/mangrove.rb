# typed: strict
# frozen_string_literal: true

# ==============================================================================
# sorbet - tapioca - compilers - enumerize
# ==============================================================================
require "tapioca/dsl"
require "sorbet-runtime"
require "mangrove/control_flow"

::Method.prepend(T::CompatibilityPatches::MethodExtensions)

module Tapioca
  module Compilers
    class Enumerize < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member { { fixed: T.class_of(::Mangrove::ControlFlow::Handler) } }

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        all_classes.find_all { |c| c < ::Mangrove::ControlFlow::Handler }
      end

      sig { override.void }
      def decorate
        root.create_path(constant) do |klass|
          # constant.instance_variable_get(:@__mangrove_flow_controlled_method_names).each do |method_name|
          #   klass.create_method(method_name, parameters: [create_rest_param("args", type: "T.untyped")], return_type: "T.untyped")
          # end
        end
      end
    end
  end
end
