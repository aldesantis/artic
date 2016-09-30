# frozen_string_literal: true
module Artic
  module Collection
    class AvailabilityCollection < Array
      def normalize
        normalized_availabilities = sort.group_by(&:identifier).values.flat_map do |availabilities|
          availabilities.inject([]) do |accumulator, availability|
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
        end

        self.class.new normalized_availabilities
      end
    end
  end
end
