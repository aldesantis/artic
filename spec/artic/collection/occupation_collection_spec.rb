# frozen_string_literal: true
RSpec.describe Artic::Collection::OccupationCollection do
  subject(:collection) { described_class.new(occupations) }

  let(:occupations) do
    [
      Artic::Occupation.new(Date.today, '10:00'..'15:00'),
      Artic::Occupation.new(Date.today, '15:30'..'17:00')
    ]
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
