RSpec.describe Artic::Calendar do
  subject(:calendar) { described_class.new }

  it 'exposes availabilities' do
    expect(calendar.availabilities).to be_instance_of(Artic::Collection::AvailabilityCollection)
  end

  it 'exposes occupations' do
    expect(calendar.occupations).to be_instance_of(Artic::Collection::OccupationCollection)
  end
end
