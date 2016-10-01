# frozen_string_literal: true
RSpec.describe Artic::Occupation do
  subject(:occupation) { described_class.new(date, time_range) }

  let(:date) { Date.today }
  let(:time_range) { '10:00'..'12:00' }

  describe '#to_range' do
    it 'converts the occupation to a range of DateTimes' do
      expect(occupation.to_range).to eq(Range.new(
        DateTime.parse("#{date} #{time_range.min}"),
        DateTime.parse("#{date} #{time_range.max}")
      ))
    end
  end

  describe '#overlaps?' do
    it 'return true if the occupation overlaps the availability' do
      availability = Artic::Availability.new(Date.today, '09:00'..'18:00')
      expect(occupation.overlaps?(availability)).to be true
    end

    it 'return false if the occupation does not overlap the availability' do
      availability = Artic::Availability.new(Date.today, '12:15'..'14:00')
      expect(occupation.overlaps?(availability)).to be false
    end
  end

  describe '#covers?' do
    it 'return true if the occupation completely covers the availability' do
      availability = Artic::Availability.new(Date.today, '10:00'..'12:00')
      expect(occupation.overlaps?(availability)).to be true
    end

    it 'return false if the occupation does not completely cover the availability' do
      availability = Artic::Availability.new(Date.today, '09:00'..'12:00')
      expect(occupation.overlaps?(availability)).to be true
    end
  end
end
