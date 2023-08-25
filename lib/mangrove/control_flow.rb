# typed: true
# frozen_string_literal: true

require_relative "control_flow/control_signal"
require_relative "control_flow/rewriter"

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

        def singleton_method_added(method_name)
          T.bind(self, T.all(ClassMethods, Module))

          super

          unless @__inside_mangrove_control_flow
            original_method = method(method_name)

            wrap_original_method_to_handle_flow_control_exception(original_method)
          end
        end

        def method_added(method_name)
          T.bind(self, T.all(ClassMethods, Module))

          super

          unless @__inside_mangrove_control_flow
            original_method = instance_method(method_name)

            wrap_original_method_to_handle_flow_control_exception(original_method)
          end
        end

        sig { params(signal: ControlFlow::ControlSignal).void }
        def handle_flow_control_exception(signal)
          signal.inner_value
        end

        sig { params(original_method: T.any(Method, UnboundMethod)).void }
        def wrap_original_method_to_handle_flow_control_exception(original_method)
          T.bind(self, T.class_of(Kernel))

          @__mangrove_flow_controlled_method_names ||= T.let(
            {},
            T.nilable(T::Hash[Symbol, T::Set[Symbol]])
          )

          @__mangrove_flow_controlled_method_names[name.to_s.intern] ||= T.let(Set.new, T::Set[Symbol])

          return if T.cast(@__mangrove_flow_controlled_method_names[name.to_s.intern], T::Set[Symbol]).include?(original_method.name)

          begin
            @__inside_mangrove_control_flow = T.let(true, T.nilable(T::Boolean))

            class_eval(Mangrove::ControlFlow.impl!(original_method))
          ensure
            @__inside_mangrove_control_flow = false
          end

          T.cast(@__mangrove_flow_controlled_method_names[name.to_s.intern], T::Set[Symbol]) << original_method.name
        end

        sig { returns(T.nilable(T::Hash[Symbol, T::Set[Symbol]])) }
        attr_reader :__mangrove_flow_controlled_method_names
      end

      mixes_in_class_methods(ClassMethods)
    end
  end
end
