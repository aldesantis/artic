module Artic
  class Availability
    DAYS_OF_WEEK = %i(monday tuesday wednesday thursday friday saturday sunday)

    attr_reader :day_of_week, :date, :time_range

    def initialize(dow_or_date, time_range)
      @date = dow_or_date if dow_or_date.is_a?(Date)
      @day_of_week = (@date ? @date.strftime('%A').downcase : dow_or_date).to_sym
      @time_range = time_range.is_a?(TimeRange) ? time_range : TimeRange.new(time_range.min, time_range.max)

      validate_day_of_week
    end

    def identifier
      date || day_of_week
    end

    def ==(other)
      identifier == other.identifier && time_range == other.time_range
    end

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
