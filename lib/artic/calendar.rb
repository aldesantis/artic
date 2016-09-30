# frozen_string_literal: true
module Artic
  class Calendar
    attr_reader :availabilities, :occupations

    def initialize
      @availabilities = Collection::AvailabilityCollection.new
      @occupations = Collection::OccupationCollection.new
    end
  end
end
