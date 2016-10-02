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

  describe '#bisect' do
    let(:availability) { Artic::Availability.new(date.strftime('%A').downcase, '08:00'..'18:00') }

    it 'splits the provided availability' do
      expect(occupation.bisect(availability)).to eq([
        Artic::Availability.new(date, '08:00'..'09:00'),
        Artic::Availability.new(date, '13:00'..'18:00')
      ])
    end
  end
end
