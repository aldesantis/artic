# A.R.TI.C.

[![Gem Version](https://img.shields.io/gem/v/artic.svg?maxAge=3600&style=flat-square)](https://rubygems.org/gems/artic)
[![Build Status](https://img.shields.io/travis/alessandro1997/artic.svg?maxAge=3600&style=flat-square)](https://travis-ci.org/alessandro1997/artic)
[![Dependency Status](https://img.shields.io/gemnasium/alessandro1997/artic.svg?maxAge=3600&style=flat-square)](https://gemnasium.com/github.com/alessandro1997/artic)
[![Code Climate](https://img.shields.io/codeclimate/github/alessandro1997/artic.svg?maxAge=3600&style=flat-square)](https://codeclimate.com/github/alessandro1997/artic)

**A** **R**uby gem for **TI**me **C**omputations.

A.R.TI.C. can take questions like:

> If I'm available 9am-5pm on Mondays and I have a meeting from 10am to 1pm and another from 3pm
> to 4pm next Monday, when am I _free_ next Monday?

And give you an answer like:

> You are free in these time slots:
>
> - 9am-10am;
> - 1pm-3pm;
> - 4pm-5pm.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artic

## Usage

First of all, you will need to create a new calendar:

```ruby
calendar = Artic::Calendar.new
```

### Setting available times

Now you can start defining the free slots in your calendar:

```ruby
calendar.availabilities << Artic::Availability.new(:monday, '09:00'..'11:00')
calendar.availabilities << Artic::Availability.new(:monday, '11:00'..'13:00')
calendar.availabilities << Artic::Availability.new(:monday, '15:00'..'19:00')
```

If you want, you can also use specific dates in place of days of the week:

```ruby
calendar.availabilities << Artic::Availability.new(Date.parse('2016-10-03'), '15:00'..'19:00')
```

Or you can mix the two! In this case, we won't consider the availability slots for that day of the
week when calculating availabilities:

```ruby
calendar.availabilities << Artic::Availability.new(:monday, '09:00'..'17:00')

# Only available 15-19 on Monday, October 3rd 2016.
calendar.availabilities << Artic::Availability.new(Date.parse('2016-10-03'), '15:00'..'19:00')
```

### Defining occupations

You can also define some specific slots when you will be busy with something:

```ruby
calendar.occupations << Artic::Occupation.new(Date.parse('2016-09-26'), '10:00'..'12:00'))
```

The times do not have to respect your availability slots:

```ruby
calendar.occupations << Artic::Occupation.new(Date.parse('2016-09-26'), '18:00'..'20:00'))
```

### Computing available slots

This is where the fun part begins. Suppose you want to get your work hours on Mondays:

```ruby
calendar.available_slots_on(:monday)
# => Artic::Collection::AvailabilityCollection[
#   Artic::Availability<:monday, 09:00..13:00>,
#   Artic::Availability<:monday, 15:00..19:00>
# ]

# We overrode this, remember?
calendar.available_slots_on(Date.parse('2016-10-03'))
# => Artic::Collection::AvailabilityCollection[
#   Artic::Availability<2016-10-03 15:00..10:00>
# ]
```

### Computing free slots

Or maybe you want to see when you have time for a meeting a particular Monday?

In that case, use `#free_slots_on` and we'll take care of removing any occupied times from your
available slots:

```ruby
calendar.free_slots_on(Date.parse('2016-09-26'))
# => Artic::Collection::AvailabilityCollection[
#   Artic::Availability<2016-09-26 09:00..13:00>,
#   Artic::Availability<2016-09-26 15:00..18:00>
# ]
```

## Caveats

- All times should be in the same timezone (ideally, UTC).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alessandro1997/artic.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## To do

- [ ] Add support for buffer (e.g. I want 15 minutes between meetings)
- [ ] Add support for other time notations (e.g. `4:00`, `4pm`, ...)
