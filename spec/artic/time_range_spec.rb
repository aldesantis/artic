# frozen_string_literal: true
RSpec.describe Artic::TimeRange do
  subject(:time_range) { described_class.new('09:00', '18:00') }

  it 'cannot be initialized with an invalid start time' do
    expect {
      described_class.new('09:61', '18:00')
    }.to raise_error(ArgumentError)
  end

  it 'cannot be initialized with an invalid end time' do
    expect {
      described_class.new('09:00', '24:00')
    }.to raise_error(ArgumentError)
  end

  it 'cannot be initialized when the start time is after the end time' do
    expect {
      described_class.new('18:00', '09:00')
    }.to raise_error(ArgumentError)
  end

  describe '#overlaps?' do
    it 'returns true when the two ranges intersect' do
      range1 = described_class.new('09:00', '18:00')
      range2 = described_class.new('18:00', '20:00')

      expect(range1.overlaps?(range2)).to be true
    end

    it 'returns true when the one range completely covers the other' do
      range1 = described_class.new('09:00', '18:00')
      range2 = described_class.new('08:00', '19:00')

      expect(range1.overlaps?(range2)).to be true
    end

    it 'is commutative' do
      range1 = described_class.new('09:00', '18:00')
      range2 = described_class.new('18:00', '20:00')

      expect(range2.overlaps?(range1)).to be true
    end

    it 'returns false when the two ranges do not overlap' do
      range1 = described_class.new('09:00', '18:00')
      range2 = described_class.new('18:01', '20:00')

      expect(range1.overlaps?(range2)).to be false
    end
  end
end
