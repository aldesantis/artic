module Artic
  class TimeRange < Range
    TIME_REGEX = /\A^(0\d|1\d|2[0-3]):[0-5]\d$\z/

    def initialize(min, max)
      super
      validate_range
    end

    def overlaps?(other)
      min <= other.max && max >= other.min
    end

    private

    def validate_range
      fail(
        ArgumentError,
        "#{min} is not a valid time"
      ) unless min =~ TIME_REGEX

      fail(
        ArgumentError,
        "#{min} is not a valid time"
      ) unless max =~ TIME_REGEX

      fail(
        ArgumentError,
        "#{min} is greater than #{max}"
      ) if min > max
    end
  end
end
