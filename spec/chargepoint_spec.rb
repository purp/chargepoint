RSpec.describe ChargePoint do
  it 'should have a version number' do
    expect {ChargePoint::VERSION}.not_to raise_error
  end
end