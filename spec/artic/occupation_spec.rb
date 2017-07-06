# frozen_string_literal: true

RSpec.describe Artic::Occupation do
  subject(:occupation) { described_class.new(date, time_range) }

  let(:date) { Date.today }
  let(:time_range) { '09:00'..'13:00' }

  describe '#to_range' do
    it 'converts the occupation to a range of DateTimes' do
      expect(occupation.to_range).to eq(Range.new(
        DateTime.parse("#{date} #{time_range.min}"),
        DateTime.parse("#{date} #{time_range.max}")
      ))
    end
  end

  describe '#covers?' do
    it 'returns true if the occupation completely covers the availability' do
      availability = Artic::Availability.new(Date.today, '10:00'..'12:00')
      expect(occupation.overlaps?(availability)).to be true
    end

    it 'returns false if the occupation does not completely cover the availability' do
      availability = Artic::Availability.new(Date.today, '09:00'..'12:00')
      expect(occupation.overlaps?(availability)).to be true
    end
  end

  describe '#overlaps?' do
    it 'returns true if the occupation overlaps the availability' do
      availability = Artic::Availability.new(Date.today, '09:00'..'18:00')
      expect(occupation.overlaps?(availability)).to be true
    end

    it 'returns false if the occupation does not overlap the availability' do
      availability = Artic::Availability.new(Date.today, '13:15'..'14:00')
      expect(occupation.overlaps?(availability)).to be false
    end

    it 'returns false if the availability is for another day' do
      availability = Artic::Availability.new(Date.today + 1, '09:00'..'18:00')
      expect(occupation.overlaps?(availability)).to be false
    end
  end

  describe '#<=>' do
    it 'compares the time ranges' do
      expect([
        Artic::Availability.new(Date.today + 1, '13:00'..'15:00'),
        Artic::Availability.new(Date.today, '10:00'..'12:00'),
        Artic::Availability.new(Date.today, '08:00'..'08:00')
      ].sort).to eq([
        Artic::Availability.new(Date.today, '08:00'..'08:00'),
        Artic::Availability.new(Date.today, '10:00'..'12:00'),
        Artic::Availability.new(Date.today + 1, '13:00'..'15:00')
      ])
    end
  end

  describe '#==' do
    it 'returns true when both the dates and the time ranges are equal' do
      occupation1 = described_class.new(Date.today, '09:00'..'18:00')
      occupation2 = described_class.new(Date.today, '09:00'..'18:00')

      expect(occupation1).to eq(occupation2)
    end

    it 'returns false when the dates are different' do
      occupation1 = described_class.new(Date.today, '09:00'..'18:00')
      occupation2 = described_class.new(Date.today + 1, '09:00'..'18:00')

      expect(occupation1).not_to eq(occupation2)
    end

    it 'returns false when the dates are the equal but the time ranges are not' do
      occupation1 = described_class.new(Date.today, '09:00'..'18:00')
      occupation2 = described_class.new(Date.today, '19:00'..'20:00')

      expect(occupation1).not_to eq(occupation2)
    end
  end

  describe '#bisect' do
    let(:availability) { Artic::Availability.new(date.strftime('%A').downcase, '08:00'..'18:00') }

    it 'splits the provided availability' do
      expect(occupation.bisect(availability)).to eq([
        Artic::Availability.new(date, '08:00'..'09:00'),
        Artic::Availability.new(date, '13:00'..'18:00')
      ])
    end

    context 'when the occupation does not overlap the availability' do
      let(:availability) { Artic::Availability.new(date + 1, '08:00'..'18:00') }

      it 'returns the original availability' do
        expect(occupation.bisect(availability)).to eq([availability])
      end
    end

    context 'when the occupation covers the availability' do
      let(:availability) { Artic::Availability.new(date, '10:00'..'11:00') }

      it 'returns an empty collection' do
        expect(occupation.bisect(availability)).to eq([])
      end
    end
  end
end
