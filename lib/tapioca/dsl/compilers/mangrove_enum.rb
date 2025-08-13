# typed: strict
# frozen_string_literal: true

require "mangrove"
require "tapioca/dsl"

# @api private
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

          variants = constant
            .constants
            .filter_map { |variant_name|
              maybe_variant = constant.const_get(variant_name, false)

              if maybe_variant.instance_variable_defined?(:@__mangrove__enum_inner_type)
                maybe_variant
              end
            }
            .sort_by { |variant| variant.name.to_s }

          inner_types = variants.map { |variant|
            inner_type = runtime_type_to_type_name(variant.instance_variable_get(:@__mangrove__enum_inner_type))
            constant_type.create_class(variant.name.gsub(/.*::/, ""), superclass_name: constant_type.fully_qualified_name) { |variant_type|
              variant_type.create_method("initialize", parameters: [create_param("inner", type: inner_type)], return_type: "void")
              variant_type.create_method("serialize", parameters: [create_param("inner_serialization_methods", type: "T.nilable(T::Array[Symbol])")], return_type: "T::Hash[Symbol, T.untyped]")
              variant_type.create_method("inner", return_type: inner_type)
              variant_type.create_method("as_super", return_type: constant.name.to_s)
              variant_type.sort_nodes!
            }

            inner_type
          }

          return_type = if inner_types.size == 1
                          T.must(inner_types.first)
                        else
                          "T.any(#{inner_types.join(", ")})"
                        end

          constant_type.create_method("inner", return_type:)
          constant_type.create_method("serialize", parameters: [create_param("inner_serialization_methods", type: "T.nilable(T::Array[Symbol])")], return_type: "T::Hash[Symbol, T.untyped]")
          constant_type.create_method("deserialize", parameters: [create_param("hash", type: "T::Hash[T.any(Symbol, String), T.untyped]"), create_param("inner_deserialization_methods", type: "T.nilable(T::Array[Symbol])")], return_type: constant.name)
          constant_type.create_method("as_super", return_type: constant.name.to_s)
          constant_type.sort_nodes!
        }
      end

      private

      sig { params(runtime_type: T.untyped).returns(String) }
      def runtime_type_to_type_name(runtime_type)
        if runtime_type.is_a?(Array)
          content = runtime_type.map { |inner|
            runtime_type_to_type_name(inner)
          }.join(", ")

          "[#{content}]"
        elsif runtime_type.is_a?(Hash)
          content = runtime_type.map { |k, v|
            unless k.is_a?(Symbol) || k.is_a?(String)
              raise "shape key must be Symbol or String"
            end

            "#{k}: #{runtime_type_to_type_name(v)}"
          }.join(", ")

          "{ #{content} }"
        else
          runtime_type.to_s
        end
      end
    end
  end
end
