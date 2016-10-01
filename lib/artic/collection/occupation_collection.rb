# frozen_string_literal: true
module Artic
  module Collection
    # Keeps a collection of occupations.
    #
    # @author Alessandro Desantis
    class OccupationCollection < Array
      # Sorts the occupations in the collection, then bisects the availability until all the
      # occupations have been accounted for.
      #
      # @param availability [Availability]
      #
      # @return AvailabilityCollection
      #
      # @see Occupation#bisect
      def bisect(availability)
        availabilities = sort.inject([availability]) do |accumulator, occupation|
          accumulator + occupation.bisect(accumulator.pop)
        end

        AvailabilityCollection.new availabilities
      end
    end
  end
end
