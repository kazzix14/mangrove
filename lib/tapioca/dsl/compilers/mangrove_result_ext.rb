# typed: strict
# frozen_string_literal: true

require "mangrove/result/ext"
require "tapioca/dsl"
require "sorbet-runtime"

module Tapioca
  module Compilers
    class MangroveResultExt < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member { { fixed: T.class_of(Mangrove::Result::Ext) } }

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        all_classes.select { |c| c < ::Mangrove::Result::Ext }
      end

      sig { override.void }
      def decorate
        return unless valid_constant_name?(constant.to_s)

        root.create_path(constant) do |klass|
          klass.create_method("in_ok", return_type: "Mangrove::Result::Ok[#{constant}]")
          klass.create_method("in_err", return_type: "Mangrove::Result::Err[#{constant}]")
        end
      rescue NameError
        # 握りつぶす
      end

      private

      sig { params(string: String).returns(T::Boolean) }
      def valid_constant_name?(string)
        Object.const_defined?(string) && !!(string =~ /\A[A-Z][a-zA-Z0-9_]*\z/)
      end
    end
  end
end
