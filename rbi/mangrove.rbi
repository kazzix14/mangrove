# typed: true

module Mangrove
  # Result is a type that represents either success (`Ok`) or failure (`Err`).
  module Result
    class Err
      class << self
        sig { type_parameters(:ErrType).params(inner: T.type_parameter(:ErrType)).returns(Mangrove::Result::Err[T.type_parameter(:ErrType)]) }
        def new(inner); end
      end
    end

    class Ok
      class << self
        sig { type_parameters(:OkType).params(inner: T.type_parameter(:OkType)).returns(Mangrove::Result::Ok[T.type_parameter(:OkType)]) }
        def new(inner); end
      end
    end
  end
end
