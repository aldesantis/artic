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

  describe '#normalize' do
    it 'returns another AvailabilityCollection' do
      expect(collection.normalize).to be_instance_of(described_class)
    end

    it 'sorts and merges contiguous slots together' do
      expect(collection.normalize).to match_array([
        Artic::Availability.new(:monday, '09:00'..'13:00'),
        Artic::Availability.new(:monday, '15:00'..'19:00'),
        Artic::Availability.new(:tuesday, '09:00'..'18:00'),
        Artic::Availability.new(Date.parse('2016-09-30'), '09:00'..'18:00')
      ])
    end
  end
end
