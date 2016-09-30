# frozen_string_literal: true
module Artic
  # An occupation represents a slot of time in a given date where you are not available.
  #
  # @author Alessandro Desantis
  class Occupation
    attr_reader :date, :time_range

    # Initializes the occupation.
    #
    # @param date [Date] the date of the occupation
    # @param time_range [TimeRange|Range] the time range of the occupation
    def initialize(date, time_range)
      @date = date
      @time_range = TimeRange.build(time_range)
    end

    # Converts the occupation to a range of +DateTime+ objects.
    #
    # @return [Range]
    #
    # @see TimeRange#with_date
    def to_range
      time_range.with_date(date)
    end

    # Returns whether the occupation overlaps the availability (i.e. whether there's at least one
    # moment in time shared by both the availability and the occupation).
    #
    # @param availability [Availability]
    #
    # @return [Boolean]
    def overlaps?(availability)
      availability_range = availability.time_range.with_date(date)
      (availability_range.min - to_range.max) * (to_range.min - availability_range.max).positive?
    end

    # Returns whether the occupation covers the availability (i.e. whether all moments of the
    # availability are also part of the occupation).
    #
    # @param availability [Availability]
    #
    # @return [Boolean]
    def covers?(availability)
      availability_range = availability.time_range.with_date(date)
      to_range.min <= availability_range.min && to_range.max >= availability_range.max
    end
  end
end
