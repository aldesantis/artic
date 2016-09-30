# frozen_string_literal: true
RSpec.describe Artic::Collection::AvailabilityCollection do
  subject(:collection) { described_class.new(availabilities) }

  let(:availabilities) do
    [
      Artic::Availability.new(Date.parse('2016-09-30'), '09:00'..'17:00'),
      Artic::Availability.new(:monday, '11:00'..'13:00'),
      Artic::Availability.new(Date.parse('2016-09-30'), '12:00'..'18:00'),
      Artic::Availability.new(:tuesday, '09:00'..'18:00'),
      Artic::Availability.new(:monday, '15:00'..'19:00'),
      Artic::Availability.new(:monday, '09:00'..'11:00')
    ]
  end

  describe '#identifiers' do
    it 'returns all identifiers in the collection' do
      expect(collection.identifiers).to match_array([
        Date.parse('2016-09-30'),
        :monday,
        :tuesday
      ])
    end
  end

  describe '#by_identifier' do
    it 'returns all availabilities for the given identifier' do
      expect(collection.by_identifier(Date.parse('2016-09-30'))).to match_array([
        Artic::Availability.new(Date.parse('2016-09-30'), '09:00'..'17:00'),
        Artic::Availability.new(Date.parse('2016-09-30'), '12:00'..'18:00')
      ])
    end
  end

  describe '#normalize' do
    it 'returns another AvailabilityCollection' do
      expect(collection.normalize(:monday)).to be_instance_of(described_class)
    end

    it 'sorts and merges slots for that identifier' do
      expect(collection.normalize(:monday)).to eq([
        Artic::Availability.new(:monday, '09:00'..'13:00'),
        Artic::Availability.new(:monday, '15:00'..'19:00')
      ])
    end
  end

  describe '#normalize_all' do
    it 'returns another AvailabilityCollection' do
      expect(collection.normalize_all).to be_instance_of(described_class)
    end

    it 'sorts and merges all slots' do
      expect(collection.normalize_all).to eq([
        Artic::Availability.new(:monday, '09:00'..'13:00'),
        Artic::Availability.new(:monday, '15:00'..'19:00'),
        Artic::Availability.new(:tuesday, '09:00'..'18:00'),
        Artic::Availability.new(Date.parse('2016-09-30'), '09:00'..'18:00')
      ])
    end
  end
end
