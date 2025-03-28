# typed: true
# frozen_string_literal: true

module Mangrove
  module TryFromExt
    extend T::Sig
    extend T::Helpers

    include Kernel

    sig {
      type_parameters(:I, :O, :E)
        .params(
          from: T::Class[T.type_parameter(:I)],
          _to: T::Class[T.type_parameter(:O)],
          err: T::Class[T.type_parameter(:E)],
          block: T.proc.params(arg: T.type_parameter(:I)).returns(Mangrove::Result[T.type_parameter(:O), T.type_parameter(:E)])
        ).void
    }
    def try_convert_from(from:, _to:, err:, &block)
      T.bind(self, T::Class[T.type_parameter(:O)])

      vars = from.instance_variable_get(:@convertable_to) || {}
      vars[self] = block
      from.instance_variable_set(:@convertable_to, vars)

      @convertable_from ||= {}
      @convertable_from[from] = [err, block]

      into_t = T.cast(self, Class)

      from.define_method("try_into_#{T.must_because(into_t.name) { "name is required" }.gsub(/::|([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase}") do
        proc = T.unsafe(self).class.ancestors.lazy.map { |klass| klass.instance_variable_get(:@convertable_to)&.[](into_t) }.find(&:itself)

        proc.call(self)
      end
    end
  end
end
