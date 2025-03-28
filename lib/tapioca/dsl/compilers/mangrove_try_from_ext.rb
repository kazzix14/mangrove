# typed: true
# frozen_string_literal: true

require "mangrove/try_from_ext"
require "tapioca/dsl"
require "sorbet-runtime"

module Tapioca
  module Compilers
    class TryFromExt < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member { { fixed: T.class_of(Mangrove::TryFromExt) } }

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        all_classes.select { |c| c.singleton_class < ::Mangrove::TryFromExt }
      end

      sig { override.void }
      def decorate
        return if constant.instance_variable_get(:@convertable_from).nil? || constant.instance_variable_get(:@convertable_from).empty?

        constant.instance_variable_get(:@convertable_from)&.each do |convertable_from, values|
          err_constant, _block = values
          root.create_path(convertable_from) do |klass|
            klass.create_method("try_into_#{constant.to_s.gsub(/::|([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase}", return_type: "Mangrove::Result[#{constant}, #{err_constant}]")
          end
        end
      end
    end
  end
end
