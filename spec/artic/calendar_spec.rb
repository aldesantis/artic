# frozen_string_literal: true
RSpec.describe Artic::Calendar do
  subject(:calendar) { described_class.new }

  let(:availability_collection) { instance_double('Artic::Collection::AvailabilityCollection') }
  let(:occupation_collection) { instance_double('Artic::Collection::OccupationCollection') }

  before do
    allow(Artic::Collection::AvailabilityCollection).to receive(:new)
      .and_return(availability_collection)

    allow(Artic::Collection::OccupationCollection).to receive(:new)
      .and_return(occupation_collection)
  end

  it 'exposes availabilities' do
    expect(availability_collection).to eq(availability_collection)
  end

  it 'exposes occupations' do
    expect(calendar.occupations).to eq(occupation_collection)
  end

  describe '#available_slots_on' do
    let(:slots) { calendar.available_slots_on(identifier) }

    let(:normalized_availabilities) { instance_double('Artic::Collection::AvailabilityCollection') }

    context 'when a valid identifier is passed' do
      let(:identifier) { [Date.today, :monday].sample }

      before do
        allow(availability_collection).to receive(:identifier?)
          .with(identifier)
          .and_return(true)

        allow(availability_collection).to receive(:normalize)
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
        allow(availability_collection).to receive(:identifier?)
          .with(identifier)
          .and_return(false)

        allow(availability_collection).to receive(:identifier?)
          .with(wday)
          .and_return(true)

        allow(availability_collection).to receive(:normalize)
          .with(wday)
          .and_return(normalized_availabilities)
      end

      it 'normalizes availabilities for the weekday' do
        expect(calendar.available_slots_on(identifier)).to eq(normalized_availabilities)
      end
    end
  end

  describe '#free_slots_on' do
    let(:date) { Date.today }
    let(:normalized_availabilities) { [availability] }
    let(:bisected_availabilities) do
      [
        instance_double('Artic::Availability'),
        instance_double('Artic::Availability')
      ]
    end
    let(:availability) { instance_double('Artic::Availability') }
    let(:bisected_collection) { instance_double('Artic::Collection::AvailabilityCollection') }

    before do
      allow(availability_collection).to receive(:identifier?)
        .with(date)
        .and_return(true)

      allow(availability_collection).to receive(:normalize)
        .with(date)
        .and_return(normalized_availabilities)

      allow(occupation_collection).to receive(:bisect).and_return(bisected_availabilities)

      allow(Artic::Collection::AvailabilityCollection).to receive(:new)
        .with(bisected_availabilities)
        .and_return(bisected_collection)
    end

    it 'returns a new collection with bisected availabilities' do
      expect(calendar.free_slots_on(date)).to eq(bisected_collection)
    end
  end
end
