# typed: true
# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity

class TrueClass
  extend T::Sig

  def into_result(*args)
    if args.empty?
      if self
        Mangrove::Result::Ok.new(self)
      else
        Mangrove::Result::Err.new(self)
      end
    elsif args.length == 1
      if self
        Mangrove::Result::Ok.new(args[0])
      else
        Mangrove::Result::Err.new(args[0])
      end
    elsif args.length == 2
      if self
        Mangrove::Result::Ok.new(args[0])
      else
        Mangrove::Result::Err.new(args[1])
      end
    else
      raise ArgumentError, "Expected 0, 1, or 2 arguments, got #{args.length}"

    end
  end
end

class FalseClass
  extend T::Sig

  def into_result(*args)
    if args.empty?
      if self
        Mangrove::Result::Ok.new(self)
      else
        Mangrove::Result::Err.new(self)
      end
    elsif args.length == 1
      if self
        Mangrove::Result::Ok.new(args[0])
      else
        Mangrove::Result::Err.new(args[0])
      end
    elsif args.length == 2
      if self
        Mangrove::Result::Ok.new(args[0])
      else
        Mangrove::Result::Err.new(args[1])
      end
    else
      raise ArgumentError, "Expected 0, 1, or 2 arguments, got #{args.length}"

    end
  end
end

# rubocop:enable Metrics/PerceivedComplexity
