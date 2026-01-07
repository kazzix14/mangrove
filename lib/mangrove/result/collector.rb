# typed: true
# frozen_string_literal: true

module Mangrove
  module Result
    class Collector
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      OkType = type_member
      ErrType = type_member

      sig { params(block: T.proc.params(ctx: CollectingContext[OkType, ErrType]).returns(Result[OkType, ErrType])).returns(Result[OkType, ErrType]) }
      def collecting(&block)
        catch(:__mangrove_result_collecting_context_return) {
          block.call(CollectingContext[OkType, ErrType].new)
        }
      end
    end
  end
end
