# frozen_string_literal: true
RSpec.describe Artic::Calendar do
  subject(:calendar) { described_class.new }

  it 'exposes availabilities' do
    expect(calendar.availabilities).to be_instance_of(Artic::Collection::AvailabilityCollection)
  end

  it 'exposes occupations' do
    expect(calendar.occupations).to be_instance_of(Artic::Collection::OccupationCollection)
  end

  describe '#available_slots_on' do
    let(:slots) { calendar.available_slots_on(identifier) }

    let(:normalized_availabilities) do
      Artic::Collection::AvailabilityCollection.new([
        Artic::Availability.new(Date.today, '09:00'..'18:00')
      ])
    end

    context 'when a valid identifier is passed' do
      let(:identifier) { [Date.today, :monday].sample }

      before do
        allow(calendar.availabilities).to receive(:identifier?)
          .with(identifier)
          .and_return(true)

        allow(calendar.availabilities).to receive(:normalize)
          .with(identifier)
          .and_return(normalized_availabilities)
      end

      it 'normalizes availabilities for the identifier' do
        expect(calendar.available_slots_on(identifier)).to eq(normalized_availabilities)
      end
    end

    context 'when a date not present in the collection is passed' do
      let(:identifier) { Date.today }
      let(:wday) { identifier.strftime('%A').downcase }

      before do
        allow(calendar.availabilities).to receive(:identifier?)
          .with(identifier)
          .and_return(false)

        allow(calendar.availabilities).to receive(:identifier?)
          .with(wday)
          .and_return(true)

        allow(calendar.availabilities).to receive(:normalize)
          .with(wday)
          .and_return(normalized_availabilities)
      end

      it 'normalizes availabilities for the weekday' do
        expect(calendar.available_slots_on(identifier)).to eq(normalized_availabilities)
      end
    end
  end
end
