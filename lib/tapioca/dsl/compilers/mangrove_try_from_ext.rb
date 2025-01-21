# typed: true
# frozen_string_literal: true

require "mangrove/try_from_ext"
require "tapioca/dsl"
require "sorbet-runtime"

class Destination
  extend T::Sig
  extend Mangrove::TryFromExt

  try_convert_from(Integer, String) do |source|
    Mangrove::Result::Ok.new(source)
  end
end

module Tapioca
  module Compilers
    class TryFromExt < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member { { fixed: T.class_of(Mangrove::TryFromExt) } }

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        # pp all_classes.map(&:name).compact.find_all { _1.include?("DestinationClass") }.map { _1.singleton_class.included_modules }
        all_classes.select { |c| c.singleton_class < ::Mangrove::TryFromExt }
        # T.unsafe(ObjectSpace.each_object(Mangrove::TryFromExt).to_a)
      end

      sig { override.void }
      def decorate
        return if constant.instance_variable_get(:@convertable_from).nil? || constant.instance_variable_get(:@convertable_from).empty?

        root.create_path(constant) do |klass|
          klass.create_method("try_convert_from", type_parameters: [create_type_parameter("T")], parameters: [create_param("t", type: "T")], return_type: "Mangrove::Result[#{constant}, #{err_constant}]")
        end

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
