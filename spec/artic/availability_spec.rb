# frozen_string_literal: true
RSpec.describe Artic::Availability do
  subject(:availability) { described_class.new(date_or_dow, time_range) }

  let(:date_or_dow) { [Date.parse('2016-09-30'), :friday].sample }
  let(:time_range) { ['09:00'..'18:00', Artic::TimeRange.new('09:00', '18:00')].sample }

  context 'when initialized with a date' do
    subject(:availability) { described_class.new(date, time_range) }

    let(:date) { Date.parse('2016-09-30') }
    let(:day_of_week) { 'friday' }

    it 'sets the date' do
      expect(availability.date).to eq(date)
    end

    it 'sets the day of the week' do
      expect(availability.day_of_week).to eq(day_of_week.to_sym)
    end
  end

  context 'when initialized with a day of the week' do
    subject(:availability) { described_class.new(day_of_week, time_range) }

    let(:day_of_week) { 'friday' }

    it 'sets no date' do
      expect(availability.date).to be_nil
    end

    it 'sets the day of the week' do
      expect(availability.day_of_week).to eq(day_of_week.to_sym)
    end
  end

  context 'when the time range is a Range' do
    let(:time_range) { '09:00'..'18:00' }

    it 'converts it into a TimeRange' do
      expect(availability.time_range).to eq(Artic::TimeRange.new(time_range.min, time_range.max))
    end
  end

  context 'when the time range is a TimeRange' do
    let(:time_range) { Artic::TimeRange.new('09:00', '18:00') }

    it 'keeps the passed argument' do
      expect(availability.time_range).to eq(time_range)
    end
  end

  describe '#<=>' do
    let(:without_date) { described_class.new(:monday, time_range) }
    let(:with_date) { described_class.new(Date.parse('2016-09-30'), time_range) }

    context 'when one object has a date and the other one does not' do
      it 'puts objects without a date before those with a date' do
        expect(without_date <=> with_date).to eq(-1)
      end
    end

    context 'when both objects do not have a date' do
      it 'compares the time if the day of the week is the same' do
        smaller_time = described_class.new(:monday, '09:00'..'13:00')
        greater_time = described_class.new(:monday, '15:00'..'19:00')

        expect(smaller_time <=> greater_time).to eq(-1)
      end

      it 'compares the day of the week if the day of the week is not the same' do
        smaller_day = described_class.new(:monday, '15:00'..'19:00')
        greater_day = described_class.new(:tuesday, '09:00'..'13:00')

        expect(smaller_day <=> greater_day).to eq(-1)
      end
    end

    context 'when both objects have a date' do
      it 'compares the times if the date is the same' do
        smaller_time = described_class.new(Date.parse('2016-09-30'), '09:00'..'13:00')
        greater_time = described_class.new(Date.parse('2016-09-30'), '15:00'..'19:00')

        expect(smaller_time <=> greater_time).to eq(-1)
      end

      it 'compares the dates if the date is not the same' do
        smaller_day = described_class.new(Date.parse('2016-09-29'), '15:00'..'19:00')
        greater_day = described_class.new(Date.parse('2016-09-30'), '09:00'..'13:00')

        expect(smaller_day <=> greater_day).to eq(-1)
      end
    end
  end

  describe '#==' do
    it 'returns true when both the identifiers and the time ranges are equal' do
      availability1 = described_class.new(:monday, '09:00'..'18:00')
      availability2 = described_class.new(:monday, '09:00'..'18:00')

      expect(availability1).to eq(availability2)
    end

    it 'returns false when the identifiers are different values' do
      availability1 = described_class.new(:monday, '09:00'..'18:00')
      availability2 = described_class.new(:tuesday, '09:00'..'18:00')

      expect(availability1).not_to eq(availability2)
    end

    it 'returns false when the identifiers are different types' do
      availability1 = described_class.new(:monday, '09:00'..'18:00')
      availability2 = described_class.new(Date.parse('2016-09-30'), '09:00'..'18:00')

      expect(availability1).not_to eq(availability2)
    end

    it 'returns false when the identifiers are the equal but the time ranges are not' do
      availability1 = described_class.new(:monday, '09:00'..'18:00')
      availability2 = described_class.new(:monday, '15:00'..'20:00')

      expect(availability1).not_to eq(availability2)
    end
  end
end
