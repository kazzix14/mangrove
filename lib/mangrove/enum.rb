# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Mangrove
  class EnumVariantsScope
    extend ::T::Sig
    extend ::T::Helpers

    sig { params(parent: T::Class[T.anything]).void }
    def initialize(parent)
      @parent = parent
    end

    sig { params(block: T.proc.void).void }
    def call(&block)
      instance_eval(&block)
    end

    sig { params(variant: T::Class[T.anything], inner_type: T.untyped).void }
    def variant(variant, inner_type)
      variant.instance_variable_set(:@__mangrove__enum_inner_type, inner_type)
    end
  end
  private_constant :EnumVariantsScope

  module Enum
    extend ::T::Sig
    extend ::T::Helpers

    requires_ancestor { Module }

    sig { params(block: T.proc.bind(EnumVariantsScope).void).void }
    def variants(&block)
      receiver = block.send(:binding).receiver

      outer_code = <<~RUBY
        def self.const_missing(id)
          code = <<~NESTED_RUBY
            class \#{id} < \#{caller.send(:binding).receiver.name}
              def initialize(inner)
                @inner = T.let(inner, self.class.instance_variable_get(:@__mangrove__enum_inner_type))
              end

              def inner
                @inner
              end

              def as_super
                T.cast(self, \#{caller.send(:binding).receiver.name})
              end

              def ==(other)
                other.is_a?(self.class) && other.inner == @inner
              end
            end
          NESTED_RUBY

          class_eval(code, __FILE__, __LINE__ + 1)
          class_eval(id.to_s, __FILE__, __LINE__ + 1)
        end
      RUBY

      original_const_missing = receiver.method(:const_missing)

      receiver.class_eval(outer_code, __FILE__, __LINE__ + 1)
      EnumVariantsScope.new(receiver).call(&block)

      # Mark as sealed hear because we can not define classes in const_missing after marking as sealed
      receiver.send(:eval, "sealed!", nil, __FILE__, __LINE__)

      variants = constants.filter_map { |variant_name|
        maybe_variant = receiver.const_get(variant_name, false)

        if maybe_variant.instance_variable_defined?(:@__mangrove__enum_inner_type)
          maybe_variant
        end
      }

      receiver.class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
        @sorbet_sealed_module_all_subclasses = #{variants} # @sorbet_sealed_module_all_subclasses = #{variants}
      RUBY

      # Bring back the original const_missing
      receiver.define_singleton_method(:const_missing, original_const_missing)
    end

    sig { params(receiver: T::Class[T.anything]).void }
    def self.extended(receiver)
      code = <<~RUBY
        extend T::Sig
        extend T::Helpers

        abstract!
      RUBY

      receiver.class_eval(code)
    end
  end
end
