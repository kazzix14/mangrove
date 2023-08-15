# typed: true
# frozen_string_literal: true

module Mangrove
  # Mangrove::ControlFlow
  module ControlFlow
    # Mangrove::ControlFlow::Handler
    module Handler
      extend T::Sig
      extend T::Helpers

      interface!

      # Mangrove::ControlFlow::ClassMethods
      module ClassMethods
        extend T::Sig
        extend T::Helpers

        abstract!

        sig { params(flow_control_exception: Signal).void }
        def handle_flow_control_exception(flow_control_exception)
          flow_control_exception.inner_value
        end

        sig { params(method_name: Symbol).void }
        def wrap_original_method_to_handle_flow_control_exception(method_name)
          T.bind(self, T.class_of(Kernel))

          original_method = instance_method(method_name)

          @__mangrove_flow_controlled_method_names ||= T.let(Set.new, T.nilable(T::Set[Symbol]))

          return if @__mangrove_flow_controlled_method_names.include?(method_name)

          begin
            @__inside_mangrove_control_flow = T.let(true, T.nilable(T::Boolean))

            define_method method_name do |*args, &block|
              # FIXME: ↓がResultまたはOptionを返すことを確認する
              original_method.bind(self).call(*args, &block)
            rescue Mangrove::ControlFlow::Signal => e
              # FIXME: need type
              e.inner_value
            end
          ensure
            @__inside_mangrove_control_flow = false
          end

          @__mangrove_flow_controlled_method_names << method_name
        end

        def method_added(method_name)
          super

          unless @__inside_mangrove_control_flow
            wrap_original_method_to_handle_flow_control_exception(method_name)
          end
        end

        sig { returns(T.nilable(T::Set[Symbol])) }
        attr_reader :__mangrove_flow_controlled_method_names
      end

      mixes_in_class_methods(ClassMethods)
    end
  end
end
