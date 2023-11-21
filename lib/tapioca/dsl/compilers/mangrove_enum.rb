# typed: strict
# frozen_string_literal: true

require "mangrove"
require "tapioca/dsl"

module Tapioca
  module Compilers
    class MangroveEnum < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member { { fixed: T.class_of(::Mangrove::Enum) } }

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        all_classes.select { |c| c.singleton_class < ::Mangrove::Enum && T::AbstractUtils.abstract_module?(c) }
      end

      sig { override.void }
      def decorate
        root.create_path(constant) { |constant_type|
          constant_type.nodes.append(
            RBI::Helper.new("abstract"),
            RBI::Helper.new("sealed")
          )

          variants = constant.constants.filter_map { |variant_name|
            maybe_variant = constant.const_get(variant_name, false)

            if maybe_variant.instance_variable_defined?(:@__mangrove__enum_inner_type)
              maybe_variant
            end
          }

          inner_types = variants.map { |variant|
            inner_type = variant.instance_variable_get(:@__mangrove__enum_inner_type).to_s
            constant_type.create_class(variant.name.gsub(/.*::/, ""), superclass_name: constant_type.fully_qualified_name) { |variant_type|
              variant_type.create_method("initialize", parameters: [create_param("inner", type: inner_type)], return_type: "void")
              variant_type.create_method("inner", return_type: inner_type)
              variant_type.create_method("as_super", return_type: constant.name.to_s)
            }

            inner_type
          }

          constant_type.create_method("inner", return_type: "T.any(#{inner_types.join(", ")})")
          constant_type.create_method("as_super", return_type: constant.name.to_s)
        }
      end
    end
  end
end
