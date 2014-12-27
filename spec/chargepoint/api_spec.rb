def double_response(content)
  double("Response", :content => content)
end

def allow_auth(auth_status=true)
  response = double_response('{"auth":%s}' % auth_status)
  allow(ChargePoint::API.agent).to receive(:post).with('https://na.chargepoint.com/users/validate', anything).and_return(response)
end

def expect_auth(auth_status=true)
  response = double_response('{"auth":%s}' % auth_status)
  expect(ChargePoint::API.agent).to receive(:post).with('https://na.chargepoint.com/users/validate', anything).and_return(response)
end

def double_agent
  @original_agent = ChargePoint::API.agent
  ChargePoint::API.class_variable_set(:@@agent, double("Agent"))
end

def undouble_agent
  ChargePoint::API.class_variable_set(:@@agent, @original_agent)
end

RSpec.describe ChargePoint::API do
  subject {ChargePoint::API}

  it {is_expected.to respond_to(:authenticate)}

  it 'should have a Mechanize agent' do
    expect(subject.agent.class).to be(Mechanize)
  end

  context 'when not authenticated' do
    before :all do
      ChargePoint::API.class_variable_set(:@@authenticated, nil)
    end

    it {is_expected.not_to be_authenticated}
  end

  context 'while authenticating' do
    before :each do |example|
      double_agent
      expect_auth(example.metadata[:auth_result])
    end

    after :each do
      undouble_agent
    end

    it 'should succeed if ChargePoint says it did', :auth_result => true do
      expect(subject.authenticate({})).to be_truthy
      expect(subject).to be_authenticated
    end

    it 'should fail if ChargePoint says it did', :auth_result => false do
      expect(subject.authenticate({})).to be_falsey
      expect(subject).not_to be_authenticated
    end
  end

  context 'when authenticated' do
    before :all do
      ChargePoint::API.class_variable_set(:@@authenticated, true)
    end

    subject {ChargePoint::API}

    it {is_expected.to be_authenticated}
  end
end
