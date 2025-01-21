# typed: true
# frozen_string_literal: true

module Mangrove
  module Result
    module Ext
      extend T::Sig

      def in_ok
        Mangrove::Result::Ok.new(self)
      end

      def in_err
        Mangrove::Result::Err.new(self)
      end
    end
  end
end
