# frozen_string_literal: true

RSpec.describe Artic::TimeRange do
  subject(:time_range) { described_class.new('09:00', '18:00') }

  describe '.build' do
    context 'with a TimeRange' do
      let(:existing_range) { described_class.new('09:00', '18:00') }

      it 'returns the passed TimeRange' do
        expect(described_class.build(existing_range)).to eq(existing_range)
      end
    end

    context 'with a range of time strings' do
      let(:range_of_times) { '09:00'..'18:00' }

      it 'returns a new TimeRange' do
        expect(described_class.build(range_of_times)).to eq(described_class.new('09:00', '18:00'))
      end
    end
  end

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

  describe '#covers?' do
    let(:range1) { described_class.new('09:00', '10:00') }
    let(:range2) { described_class.new('08:00', '11:00') }

    it 'returns true when the range covers the other' do
      expect(range2.covers?(range1)).to be true
    end

    it 'returns false when the range does not cover the other' do
      expect(range1.covers?(range2)).to be false
    end
  end

  describe '#with_date' do
    let(:date) { Date.today }

    it 'converts the time range to a range of DateTimes' do
      expect(time_range.with_date(date)).to eq(Range.new(
        DateTime.parse("#{date} #{time_range.min}"),
        DateTime.parse("#{date} #{time_range.max}")
      ))
    end
  end

  describe '#bisect' do
    let(:range1) { described_class.new('09:00', '18:00') }
    let(:range2) { described_class.new('12:00', '13:00') }

    it 'returns the original range when the ranges do not overlap' do
      expect(described_class.new('18:00', '20:00').bisect(range1)).to eq([range1])
    end

    it 'returns an empty array when the range covers the other' do
      expect(range1.bisect(range2)).to eq([])
    end

    it 'bisects the provided range' do
      expect(range2.bisect(range1)).to eq([
        described_class.new('09:00', '12:00'),
        described_class.new('13:00', '18:00')
      ])
    end
  end
end
