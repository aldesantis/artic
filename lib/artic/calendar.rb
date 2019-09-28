# frozen_string_literal: true

module Artic
  # A calendar keeps track of both your availabilities and your occupations.
  #
  # @author Alessandro Desantis
  class Calendar
    # @!attribute [r] availabilities
    #   @return [Collection::AvailabilityCollection]
    #
    # @!attribute [r] occupations
    #   @return [Collection::OccupationCollection]
    attr_reader :availabilities, :occupations

    # Initializes the calendar.
    def initialize
      @availabilities = Collection::AvailabilityCollection.new
      @occupations = Collection::OccupationCollection.new
    end

    # Returns the slots available on the given day of the week or date, including any slots that
    # might be occupied on the given date.
    #
    # If the passed argument is an instance of +Date+ but no availabilities have been defined
    # for that specific date, returns any availabilities defined for that day of the week.
    #
    # @param dow_or_date [Date|Symbol] a day of the week or date
    #
    # @return Collection::AvailabilityCollection
    #
    # @example
    #   calendar.available_slots_on(:monday) # => #<Artic::Collection::AvailabilityCollection>
    # @example
    #   calendar.available_slots_on(Date.tomorrow) # => #<Artic::Collection::AvailabilityCollection>
    #
    # @see Collection::AvailabilityCollection#normalize
    def available_slots_on(dow_or_date)
      # rubocop:disable Metrics/LineLength
      if !availabilities.identifier?(dow_or_date) && dow_or_date.is_a?(Date) && availabilities.identifier?(dow_or_date.strftime('%A').downcase)
        return available_slots_on(dow_or_date.strftime('%A').downcase)
      end

      # rubocop:enable Metrics/LineLength

      availabilities.normalize dow_or_date
    end

    # Returns the slots free on the given date, computed by calling {Occupation#bisect} on each
    # of the availability slots.
    #
    # @param date [Date]
    #
    # @return Collection::AvailabilityCollection
    #
    # @see Collection::OccupationCollection#bisect
    def free_slots_on(date)
      normalized_occupations = occupations.normalize(date)
      availabilities = available_slots_on(date).flat_map do |availability|
        normalized_occupations.bisect(availability)
      end

      Collection::AvailabilityCollection.new availabilities
    end
  end
end
