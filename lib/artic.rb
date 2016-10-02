# frozen_string_literal: true
require 'tzinfo'

require 'artic/version'

require 'artic/time_range'

require 'artic/availability'
require 'artic/occupation'

require 'artic/collection/availability_collection'
require 'artic/collection/occupation_collection'

require 'artic/calendar'

# Artic is a Ruby gem for time computations.
#
# It can solve problems like: if I'm available 9am-5pm on Mondays and I have a meeting from 10am
# to 1pm and another from 3pm to 4pm next Monday, when am I free next Monday?
#
# @author Alessandro Desantis
module Artic
end
