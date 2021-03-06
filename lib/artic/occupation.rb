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

    # Converts the occupation to a range of +Time+ objects.
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
      return false unless availability.for_date?(date)

      availability_range = availability.time_range.with_date(date)
      (availability_range.min <= to_range.max) && (availability_range.max >= to_range.min)
    end

    # Returns whether the occupation covers the availability (i.e. whether all moments of the
    # availability are also part of the occupation).
    #
    # @param availability [Availability]
    #
    # @return [Boolean]
    def covers?(availability)
      return false unless availability.for_date?(date)

      availability_range = availability.time_range.with_date(date)
      to_range.min <= availability_range.min && to_range.max >= availability_range.max
    end

    # Determines whether this occupation and the one passed as an argument represent the same
    # day/time range combination, by checking for equality of both the date and the time
    # range.
    #
    # @param other [Occupation]
    #
    # @return [Boolean]
    def ==(other)
      date == other.date && time_range == other.time_range
    end

    # Compares this occupation with another one by comparing their ranges' start.
    #
    # @param other [Occupation]
    #
    # @return [Fixnum] -1 if this occupation should come before the other one, 0 if it should be
    #   in the same position, 1 if it should come after the other one
    def <=>(other)
      to_range.min <=> other.to_range.min
    end

    # Reduces the time range of the given availability or bisects it into two availabilities,
    # depending on where the occupation falls within the availability.
    #
    # If the occupation completely covers the availability, returns an empty collection.
    #
    # If the occupation does not overlap the availability at all, returns a collection with
    # the original availability.
    #
    # @param availability [Availability]
    #
    # @return Collection::AvailabilityCollection a collection of availabilities where the time
    #   slot assigned to the occupation has been removed
    #
    # @example
    #   occupation = Artic::Occupation.new(Date.today, '08:00'..'14:00')
    #   availability = Artic::Availability.new(Date.today, '09:00'..'18:00')
    #
    #   occupation.bisect(availability)
    #   # => [
    #   #   #<Artic::Availability 14:00..18:00>
    #   # ]
    #
    # @example
    #   occupation = Artic::Occupation.new(Date.today, '12:00'..'14:00')
    #   availability = Artic::Availability.new(Date.today, '09:00'..'18:00')
    #
    #   occupation.bisect(availability)
    #   # => [
    #   #   #<Artic::Availability 09:00..12:00>,
    #   #   #<Artic::Availability 14:00..18:00>
    #   # ]
    #
    # @example
    #   occupation = Artic::Occupation.new(Date.today, '16:00'..'20:00')
    #   availability = Artic::Availability.new(Date.today, '09:00'..'18:00')
    #
    #   occupation.bisect(availability)
    #   # => [
    #   #   #<Artic::Availability 09:00..16:00>
    #   # ]
    def bisect(availability)
      return Collection::AvailabilityCollection.new if covers?(availability)
      return Collection::AvailabilityCollection.new([availability]) unless overlaps?(availability)

      bisected_ranges = time_range.bisect(availability.time_range)

      availabilities = bisected_ranges.map do |bisected_range|
        Availability.new(date, bisected_range)
      end

      Collection::AvailabilityCollection.new availabilities
    end
  end
end
