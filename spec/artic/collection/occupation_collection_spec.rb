# frozen_string_literal: true

RSpec.describe Artic::Collection::OccupationCollection do
  subject(:collection) { described_class.new(occupations) }

  let(:occupations) do
    [
      Artic::Occupation.new(Date.today, '10:00'..'13:00'),
      Artic::Occupation.new(Date.today + 1, '16:00'..'17:00'),
      Artic::Occupation.new(Date.today, '15:30'..'17:00'),
      Artic::Occupation.new(Date.today, '12:00'..'15:00'),
      Artic::Occupation.new(Date.today + 1, '13:00'..'15:00')
    ]
  end

  describe '#dates' do
    it 'returns all dates in the collection' do
      expect(collection.dates).to match_array([
        Date.today,
        Date.today + 1
      ])
    end
  end

  describe '#date?' do
    it 'returns true with an existing date' do
      expect(collection.date?(Date.today)).to be true
    end

    it 'returns false with a non-existing date' do
      expect(collection.date?(Date.today - 1)).to eq false
    end
  end

  describe '#by_date' do
    it 'returns all availabilities for the given date' do
      expect(collection.by_date(Date.today)).to match_array([
        Artic::Occupation.new(Date.today, '10:00'..'13:00'),
        Artic::Occupation.new(Date.today, '15:30'..'17:00'),
        Artic::Occupation.new(Date.today, '12:00'..'15:00')
      ])
    end
  end

  describe '#normalize' do
    it 'sorts and merges occupations for that date' do
      expect(collection.normalize(Date.today)).to eq([
        Artic::Occupation.new(Date.today, '10:00'..'15:00'),
        Artic::Occupation.new(Date.today, '15:30'..'17:00')
      ])
    end
  end

  describe '#normalize_all' do
    it 'sorts and merges all occupations' do
      expect(collection.normalize_all).to eq([
        Artic::Occupation.new(Date.today, '10:00'..'15:00'),
        Artic::Occupation.new(Date.today, '15:30'..'17:00'),
        Artic::Occupation.new(Date.today + 1, '13:00'..'15:00'),
        Artic::Occupation.new(Date.today + 1, '16:00'..'17:00')
      ])
    end
  end

  describe '#bisect' do
    let(:availability) { Artic::Availability.new(Date.today, '09:00'..'18:00') }

    it 'bisects the availabiltiy with all occupations' do
      expect(collection.bisect(availability)).to eq([
        Artic::Availability.new(Date.today, '09:00'..'10:00'),
        Artic::Availability.new(Date.today, '15:00'..'15:30'),
        Artic::Availability.new(Date.today, '17:00'..'18:00')
      ])
    end
  end
end
