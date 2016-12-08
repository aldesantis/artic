# frozen_string_literal: true
module Artic
  module Collection
    # Keeps a collection of occupations.
    #
    # @author Alessandro Desantis
    class OccupationCollection < Array
      # Returns all the dates in this collection.
      #
      # @return [Array<Date>]
      def dates
        map(&:date).uniq
      end

      # Returns whether a date exists in this collection.
      #
      # @param date [Date]
      #
      # @return [Boolean]
      def date?(date)
        dates.include? date
      end

      # Returns all the occupations for the given date, without normalizing them.
      #
      # @param date [Date]
      #
      # @return OccupationCollection
      def by_date(date)
        occupations = select { |occupation| occupation.date == date }
        self.class.new occupations
      end

      # Normalizes all the occupations with the given identifier in this collection by sorting
      # them and merging any contiguous availability slots.
      #
      # @param date [Date]
      #
      # @return AvailabilityCollection
      def normalize(date)
        occupations = by_date(date).sort

        normalized_occupations = occupations.inject([]) do |accumulator, occupation|
          next (accumulator << occupation) if accumulator.empty?

          last_occupation = accumulator.pop

          next (
            accumulator + [last_occupation, occupation]
          ) unless last_occupation.time_range.overlaps?(occupation.time_range)

          new_time_range = Range.new(
            [last_occupation.time_range.min, occupation.time_range.min].min,
            [last_occupation.time_range.max, occupation.time_range.max].max
          )

          accumulator << Occupation.new(occupation.date, new_time_range)
        end

        self.class.new normalized_occupations
      end

      # Normalizes all the occupations in this collection by sorting them and merging any
      # contiguous availability slots.
      #
      # @return OccupationCollection
      #
      # @see #normalize
      def normalize_all
        normalized_occupations = dates.sort.flat_map do |date|
          normalize date
        end

        self.class.new normalized_occupations
      end

      # Sorts the occupations in the collection, then bisects the availability until all the
      # occupations have been accounted for.
      #
      # @param availability [Availability]
      #
      # @return AvailabilityCollection
      #
      # @see Occupation#bisect
      def bisect(availability)
        availabilities = normalize_all.inject([availability]) do |accumulator, occupation|
          break accumulator if accumulator.empty?
          accumulator + occupation.bisect(current_availability)
        end

        AvailabilityCollection.new availabilities
      end
    end
  end
end
