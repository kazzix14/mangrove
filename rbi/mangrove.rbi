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

class TrueClass
  sig { type_parameters(:T).params(args: T.type_parameter(:T)).returns(Mangrove::Result[T.type_parameter(:T), T.type_parameter(:T)]) }
  sig { type_parameters(:O, :E).params(args: [T.type_parameter(:O), T.type_parameter(:E)]).returns(Mangrove::Result[T.type_parameter(:O), T.type_parameter(:E)]) }
  def into_result(*args); end
end

class FalseClass
  sig { type_parameters(:T).params(args: T.type_parameter(:T)).returns(Mangrove::Result[T.type_parameter(:T), T.type_parameter(:T)]) }
  sig { type_parameters(:O, :E).params(args: [T.type_parameter(:O), T.type_parameter(:E)]).returns(Mangrove::Result[T.type_parameter(:O), T.type_parameter(:E)]) }
  def into_result(*args); end
end
