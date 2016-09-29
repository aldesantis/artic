calendar = Agenda::Calendar.new(timezone: 'UTC')

calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '09:00'..'11:00' # converted to TimeRange internally
)

calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '11:00'..'13:00' # converted to TimeRange internally
)

calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '15:00'..'19:00' # converted to TimeRange internally
)

# Boring meeting during my regular work hours
calendar.occupations << Agenda::Occupation.new(Range.new(
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 10:00:00'),
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 12:00:00')
))

# Boring meeting that ends after my regular work hours
calendar.occupations << Agenda::Occupation.new(Range.new(
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 18:00:00'),
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 20:00:00')
))

# Get my work hours (free or not) for Mondays
calendar.available_slots_on(:monday)
# =>
# [
#      TimeRange<09:00..13:00>,
#      TimeRange<15:00..19:00>
# ]

# Get my work hours (free or not) for a specific Monday
calendar.available_slots_on(Date.parse('2016-09-26'))
# =>
# [
#   ActiveSupport::TimeWithZone<2016-09-26 09:00>..ActiveSupport::TimeWithZone<2016-09-26 13:00>,
#   ActiveSupport::TimeWithZone<2016-09-26 15:00>..ActiveSupport::TimeWithZone<2016-09-26 19:00>
# ]

# Get my free slots for a specific
calendar.free_slots_on(Date.parse('2016-09-26'))
# =>
# [
#   ActiveSupport::TimeWithZone<2016-09-26 09:00>..ActiveSupport::TimeWithZone<2016-09-26 10:00>,
#   ActiveSupport::TimeWithZone<2016-09-26 12:00>..ActiveSupport::TimeWithZone<2016-09-26 13:00>
# ]
