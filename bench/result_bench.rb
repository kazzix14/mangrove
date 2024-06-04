# typed: true
# frozen_string_literal: true

require "mangrove"

require "sorbet-runtime"
require "benchmark"

COUNT = 1000000

Benchmark.bm(24) { |r|

  r.report("Exception") {
    COUNT.times do
      begin
        if rand(2).zero?
          _ok = 1
        else
          raise StandardError, "err"
        end => return_value
      rescue StandardError => e
        _err = e.message
      end
    end
  }

  r.report("Mangrove::Result") {
    COUNT.times do
      if rand(2).zero?
        T.cast(Mangrove::Result::Ok.new(1), Mangrove::Result[T.untyped, T.untyped])
      else
        T.cast(Mangrove::Result::Err.new("err"), Mangrove::Result[T.untyped, T.untyped])
      end => return_value

      if return_value.is_a?(Mangrove::Result::Ok)
        _ok = return_value.ok_inner
      else
        _err = return_value.err_inner
      end
    end
  }
}
