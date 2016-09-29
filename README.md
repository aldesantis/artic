# Agenda

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/agenda`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'agenda'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install agenda

## Usage

```ruby
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/agenda.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

