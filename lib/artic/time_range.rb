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
        range.is_a?(TimeRange) ? range : TimeRange.new(range.begin, range.end)
      end
    end

    # Initializes a new range.
    #
    # @param start_time [String] the start time (in HH:MM format)
    # @param end_time [String] the end time (in HH:MM format)
    #
    # @raise [ArgumentError] if the start time or the end time is invalid
    # @raise [ArgumentError] if the start time is after the end time
    def initialize(start_time, end_time)
      super
      validate_range
    end

    # Returns whether the two ranges overlap (i.e. whether there's at least a moment in time that
    # belongs to both ranges).
    #
    # @param other [TimeRange]
    #
    # @return [Boolean]
    def overlaps?(other)
      self.begin <= other.end && self.end >= other.begin
    end

    # Returns whether this range completely covers the one given.
    #
    # @param other [TimeRange]
    #
    # @return [Boolean]
    def covers?(other)
      self.begin <= other.begin && self.end >= other.end
    end

    # Returns a range of +Time+ objects for this time range.
    #
    # @param date [Date] the date to use for the range
    #
    # @return [Range]
    def with_date(date)
      Range.new(
        Time.parse("#{date} #{self.begin}"),
        Time.parse("#{date} #{self.end}")
      )
    end

    # Uses this range to bisect another.
    #
    # If this range does not overlap the other, returns an array with the original range.
    #
    # If this range completely covers the other, returns an empty array.
    #
    # @param other [TimeRange]
    #
    # @return [Array<TimeRange>]
    #
    # @example
    #   range1 = TimeRange.new('10:00'..'12:00')
    #   range2 = TimeRange.new('09:00'..'18:00')
    #   range3 = TimeRange.new('08:00'..'11:00')
    #
    #   range1.bisect(range2)
    #   # => [
    #   #   #<TimeRange 09:00..10:00>,
    #   #   #<TimeRange 12:00..18:00>
    #   # ]
    #
    #   range2.bisect(range1)
    #   # => []
    #
    #   range3.bisect(range2)
    #   # => [
    #   #   #<TimeRange 11:00..18:00>
    #   # ]
    #
    #   range2.bisect(range3)
    #   # => [
    #   #   #<TimeRange 08:00..09:00>
    #   # ]
    def bisect(other)
      return [other] unless overlaps?(other)
      return [] if covers?(other)

      if self.begin <= other.begin && self.end <= other.end
        [self.end..other.end]
      elsif self.begin >= other.begin && self.end <= other.end
        [
          (other.begin..self.begin),
          (self.end..other.end)
        ]
      elsif self.begin >= other.begin && self.end >= other.end
        [other.begin..self.begin]
      end
    end

    private

    def validate_range
      unless TIME_REGEX.match?(self.begin)
        fail(
          ArgumentError,
          "#{self.begin} is not a valid time"
        )
      end

      unless TIME_REGEX.match?(self.end)
        fail(
          ArgumentError,
          "#{self.end} is not a valid time"
        )
      end

      if self.begin > self.end
        fail(
          ArgumentError,
          "#{self.begin} is greater than #{self.end}"
        )
      end
    end
  end
end
