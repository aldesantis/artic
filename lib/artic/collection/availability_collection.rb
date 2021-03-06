# frozen_string_literal: true

module Artic
  module Collection
    # Keeps a collection of availabilities and performs calculations on them.
    #
    # @author Alessandro Desantis
    class AvailabilityCollection < Array
      # Returns all the identifiers in this collection.
      #
      # @return [Array<Symbol|Date>]
      def identifiers
        map(&:identifier).uniq
      end

      # Returns whether an identifier exists in this collection.
      #
      # @param identifier [Symbol,Date]
      #
      # @return [Boolean]
      def identifier?(identifier)
        identifiers.include? cast_identifier(identifier)
      end

      # Returns all the availabilities with the given identifier, without normalizing them.
      #
      # @param identifier [Symbol|Date] a weekday or a date
      #
      # @return AvailabilityCollection
      def by_identifier(identifier)
        identifier = cast_identifier identifier
        availabilities = select { |availability| availability.identifier == identifier }
        self.class.new availabilities
      end

      # Normalizes all the availabilities with the given identifier in this collection by sorting
      # them and merging any contiguous availability slots.
      #
      # @param identifier [Symbol|Date]
      #
      # @return AvailabilityCollection
      def normalize(identifier)
        availabilities = by_identifier(identifier).sort

        normalized_availabilities = availabilities.inject([]) do |accumulator, availability|
          next (accumulator << availability) if accumulator.empty?

          last_availability = accumulator.pop

          unless last_availability.time_range.overlaps?(availability.time_range)
            next (
              accumulator + [last_availability, availability]
            )
          end

          new_time_range = Range.new(
            [last_availability.time_range.min, availability.time_range.min].min,
            [last_availability.time_range.max, availability.time_range.max].max
          )

          accumulator << Availability.new(availability.identifier, new_time_range)
        end

        self.class.new normalized_availabilities
      end

      # Normalizes all the availabilities in this collection by sorting them and merging any
      # contiguous availability slots.
      #
      # @return AvailabilityCollection
      #
      # @see #normalize
      def normalize_all
        normalized_availabilities = identifiers.flat_map do |identifier|
          normalize identifier
        end

        self.class.new normalized_availabilities.sort
      end

      private

      def cast_identifier(identifier)
        identifier.is_a?(String) ? identifier.to_sym : identifier
      end
    end
  end
end
