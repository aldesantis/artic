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

First of all, you will need to create a new calendar and specify its timezone:

```ruby
calendar = Agenda::Calendar.new(timezone: 'UTC')
```

Now you can start defining the free slots in your calendar:

```ruby
calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '09:00'..'11:00'
)

calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '11:00'..'13:00'
)

calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '15:00'..'19:00'
)
```

If you want, you can also use specific dates in place of days of the week:

```ruby
calendar.availabilities << Agenda::AvailabilitySlot.new(
  Date.parse('2016-10-03'),
  '15:00'..'19:00'
)
```

Or you can mix the two! In this case, we won't consider the availability slots for that day of the
week when calculating availabilities:

```ruby
calendar.availabilities << Agenda::AvailabilitySlot.new(
  :monday,
  '09:00'..'17:00'
)

# Only available 15-19 on Monday, October 3, 2016.
calendar.availabilities << Agenda::AvailabilitySlot.new(
  Date.parse('2016-10-03'),
  '15:00'..'19:00'
)
```

You can also define some specific when you will _not_ be available:

```ruby
calendar.occupations << Agenda::Occupation.new(Range.new(
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 10:00:00'),
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 12:00:00')
))
```

The times do not have to respect your availability slots:

```ruby
calendar.occupations << Agenda::Occupation.new(Range.new(
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 18:00:00'),
  ActiveSupport::TimeZone['Berlin'].parse('2016-09-26 20:00:00')
))
```

This is where the fun part begins. Suppose you want to get your general availability on Mondays:

```ruby
calendar.available_slots_on(:monday)
# => [
#      TimeRange<09:00..13:00>,
#      TimeRange<15:00..19:00>
# ]
```

Or maybe you want to see when you're available on a particular Monday?

```ruby
calendar.available_slots_on(Date.parse('2016-09-26'))
# => [
#   ActiveSupport::TimeWithZone<2016-09-26 09:00>..ActiveSupport::TimeWithZone<2016-09-26 13:00>,
#   ActiveSupport::TimeWithZone<2016-09-26 15:00>..ActiveSupport::TimeWithZone<2016-09-26 19:00>
# ]

# We overrode this, remember?
calendar.free_slots_on(Date.parse('2016-10-03'))
# => [
#   ActiveSupport::TimeWithZone<2016-09-26 15:00>..ActiveSupport::TimeWithZone<2016-09-26 19:00>
# ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/agenda.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

