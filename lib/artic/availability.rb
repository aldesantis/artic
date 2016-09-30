# frozen_string_literal: true
module Artic
  # Availability represents a slot of time in a givn day of the week or date when you're available.
  #
  # @author Alessandro Desantis
  class Availability
    DAYS_OF_WEEK = %i(monday tuesday wednesday thursday friday saturday sunday).freeze

    # @!attribute [r] day_of_week
    #   @todo Rename to +wday+
    #   @return [Symbol] the day of the week, as a lowercase symbol (e.g. +:monday+)
    #
    # @!attribute [r] date
    #   @return [Date] the date of this availability
    #
    # @!attribute [r] time_range
    #   @return [TimeRange] the time range of this availability
    attr_reader :day_of_week, :date, :time_range

    # Initializes the availability.
    #
    # @param dow_or_date [Symbol|Date] a day of the week (e.g. +:monday+) or date
    # @param time_range [TimeRange|Range] a time range
    #
    # @raise [ArgumentError] if an invalid day of the week is passed
    def initialize(dow_or_date, time_range)
      @date = dow_or_date if dow_or_date.is_a?(Date)
      @day_of_week = (@date ? @date.strftime('%A').downcase : dow_or_date).to_sym
      @time_range = TimeRange.build(time_range)

      validate_day_of_week
    end

    # Returns the identifier used to create this availability (i.e. either a day of the week or
    # date).
    #
    # @return [Date|Symbol]
    def identifier
      date || day_of_week
    end

    # Determines whether this availability and the one passed as an argument represent the same
    # day/time range combination, by checking for equality of both the identifier and the time
    # range.
    #
    # @param other [Availability]
    #
    # @return [Boolean]
    def ==(other)
      identifier == other.identifier && time_range == other.time_range
    end

    # Returns whether this availability should be before, after or in the same position of the
    # availability passed as an argument, by following these rules:
    #
    #   * availabilities with a weekday come before those with a date;
    #   * if both availabilities are for a weekday, the day and time ranges are compared;
    #   * if both availabilities are for a date, the date and time ranges are compared.
    #
    # @return [Fixnum] -1 if this availability should come before the argument, 0 if it should
    #   be at the same position, 1 if it should come after the argument.
    #
    # @see TimeRange#<=>
    def <=>(other)
      # availabilities for weekdays come before availabilities for specific dates
      return -1 if date.nil? && !other.date.nil?
      return 1 if !date.nil? && other.date.nil?

      if date.nil? && other.date.nil? # both availabilities are for a weekday
        if day_of_week == other.day_of_week # availabilities are for the same weekday
          time_range.min <=> other.time_range.min # compare times
        else # availabilities are for different weekdays
          index1 = DAYS_OF_WEEK.index(day_of_week)
          index2 = DAYS_OF_WEEK.index(other.day_of_week)

          index1 <=> index2 # compares weekdays
        end
      else # both availabilities are for a date
        if date == other.date # both availabilities are for the same date
          time_range.min <=> other.time_range.min # compare times
        else # availabilities are for different dates
          date <=> other.date # compare dates
        end
      end
    end

    private

    def validate_day_of_week
      fail(
        ArgumentError,
        "#{day_of_week} is not a valid day of the week"
      ) unless DAYS_OF_WEEK.include?(day_of_week)
    end
  end
end
