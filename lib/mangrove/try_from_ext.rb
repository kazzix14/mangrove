# typed: true
# frozen_string_literal: true

module Mangrove
  module TryFromExt
    extend T::Sig
    extend T::Helpers

    sig { type_parameters(:T, :E).params(t: T::Class[T.type_parameter(:T)], e: T::Class[T.type_parameter(:E)], block: T.proc.params(arg: T.type_parameter(:T)).returns(Mangrove::Result[T.type_parameter(:T), T.type_parameter(:E)])).void }
    def try_convert_from(t, e, &block)
      vars = t.instance_variable_get(:@convertable_to) || {}
      vars[self] = block
      t.instance_variable_set(:@convertable_to, vars)

      @convertable_from ||= {}
      @convertable_from[t] = [e, block]

      into_t = T.cast(self, Class)

      t.define_method("try_into_#{T.must_because(into_t.name) { "name is required" }.gsub(/::|([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase}") do
        T.unsafe(self).class.instance_variable_get(:@convertable_to)[into_t].call(self)
      end
    end
  end
end
