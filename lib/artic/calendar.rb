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
      if !availabilities.identifier?(dow_or_date) && dow_or_date.is_a?(Date) && availabilities.identifier?(dow_or_date.strftime('%A').downcase)
        return available_slots_on(dow_or_date.strftime('%A').downcase)
      end

      availabilities.normalize dow_or_date
    end

    # Returns the slots free on the given date, computed by taking the available slots for the date
    # and removing any occupied portions.
    #
    # @return Collection::AvailabilityCollection
    def free_slots_on(date)
      slots = available_slots_on(date).inject([]) do |accumulator, slot|
        overlapping_occupations = occupations.select { |occ| occ.overlaps?(slot) }

        # No overlapping sessions found: add the availability to the accumulator
        next (accumulator << slot) if overlapping_occupations.empty?

        # The session occupies the availability completely: remove the availability
        next accumulator if overlapping_occupations.any? { |occ| occ.covers?(slot) }

        accumulator + overlapping_occupations.inject([slot]) do |subaccumulator, occupation|
          last_slot = subaccumulator.pop
          slot_range = last_slot.time_range.with_date(occupation.date)
          occupation_range = occupation.to_range

          # If the occupation begins and ends before the availability, the availability starts
          # when the occupation ends
          if occupation_range.min <= slot_range.min && occupation_range.max <= slot_range.max
            subaccumulator << (occupation_range.max..slot_range.max)
          # If the occupation starts after the availability, but ends before, the availability is
          # split in two
          elsif occupation_range.min >= slot_range.min && occupation_range.max <= slot_range.max
            subaccumulator + [
              (slot_range.min..occupation_range.min),
              (occupation_range.max..slot_range.max)
            ]
          end
        end
      end.map do |datetime_range|
        Availability.new(datetime_range.min.to_date, Range.new(
          datetime_range.min.strftime('%H:%M'),
          datetime_range.max.strftime('%H:%M')
        ))
      end

      Collection::AvailabilityCollection.new(slots)
    end
  end
end
