# frozen_string_literal: true
module Artic
  # Represents a range of two times in the same day (e.g. 09:00-17:00).
  #
  # @author Alessandro Desantis
  class TimeRange < Range
    TIME_REGEX = /\A^(0\d|1\d|2[0-3]):[0-5]\d$\z/

    class << self
      # Builds a time range from the provided value.
      #
      # @param range [Range|TimeRange] a range of times (e.g. +'09:00'..'18:00'+ or
      #   a +TimeRange+ object)
      #
      # @return [TimeRange] the passed time range or a new time range
      def build(range)
        range.is_a?(TimeRange) ? range : TimeRange.new(range.min, range.max)
      end
    end

    # Initializes a new range.
    #
    # @param min [String] the start time (in HH:MM format)
    # @param max [String] the end time (in HH:MM format)
    #
    # @raise [ArgumentError] if the start time or the end time is invalid
    # @raise [ArgumentError] if the start time is after the end time
    def initialize(min, max)
      super
      validate_range
    end

    # Returns whether the two ranges overlap (i.e. whether there's at least a moment in time that
    # belongs to both ranges).
    #
    # @return [Boolean]
    def overlaps?(other)
      min <= other.max && max >= other.min
    end

    # Returns a range of +DateTime+ objects for this time range.
    #
    # @param date [Date] the date to use for the range
    #
    # @return [Range]
    def with_date(date)
      Range.new(
        DateTime.parse("#{date} #{min}"),
        DateTime.parse("#{date} #{max}")
      )
    end

    private

    def validate_range
      fail(
        ArgumentError,
        "#{min} is not a valid time"
      ) unless min =~ TIME_REGEX

      fail(
        ArgumentError,
        "#{max} is not a valid time"
      ) unless max =~ TIME_REGEX

      fail(
        ArgumentError,
        "#{min} is greater than #{max}"
      ) if min > max
    end
  end
end
