# frozen_string_literal: true
module Artic
  module Collection
    class AvailabilityCollection < Array
      def by_identifier(identifier)
        select { |availability| availability.identifier == identifier }
      end

      def identifiers
        map { |availability| availability.identifier }.uniq
      end

      def normalize_all
        normalized_availabilities = identifiers.flat_map do |identifier|
          normalize identifier
        end

        self.class.new normalized_availabilities.sort
      end

      def normalize(identifier)
        availabilities = by_identifier(identifier).sort

        normalized_availabilities = availabilities.inject([]) do |accumulator, availability|
          next (accumulator << availability) if accumulator.empty?

          last_availability = accumulator.pop

          next (
            accumulator + [last_availability, availability]
          ) unless last_availability.time_range.overlaps?(availability.time_range)

          new_time_range = Range.new(
            [last_availability.time_range.min, availability.time_range.min].min,
            [last_availability.time_range.max, availability.time_range.max].max
          )

          accumulator << Availability.new(availability.identifier, new_time_range)
        end

        self.class.new normalized_availabilities
      end
    end
  end
end
