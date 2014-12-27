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

def expect_get
  response = double_response('{}')
  expect(ChargePoint::API.agent).to receive(:get).with(include('dashboard', 'getChargeSpots', 'f_reservable', 'community_enabled_only')).and_return(response)
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

  it 'should have a list of methods requiring authentication' do
    expect(subject::AUTHENTICATED_METHODS).to be_kind_of(Array)
  end

  it 'should have a Mechanize agent' do
    expect(subject.agent.class).to be(Mechanize)
  end

  context '.dashboard_uri_for_method' do
    def testing_dashboard_uri
      ChargePoint::API.send(:dashboard_uri_for_method)
    end

    subject { @uri = testing_dashboard_uri }

    it { is_expected.to be_a(URI) }

    it 'should start with the dashboard URI' do
      expect(subject.to_s).to start_with('https://na.chargepoint.com/dashboard/')
    end

    it 'should end with the calling method name camel-cased' do
      expect(subject.to_s).to end_with('testingDashboardUri')
    end
  end

  context '.search_box_for' do
    it 'should have keys for center, southwest, and northeast corners' do
      search_box = subject.send(:search_box_for, 0, 0, 1)
      expect(search_box.keys).to contain_exactly(:lat, :lng, :sw_lat, :sw_lng, :ne_lat, :ne_lng)
    end
  end
  
  context '.params_with_filters' do
    before :each do |example|
      options = example.metadata[:options] || {}
      @params = ChargePoint::API.send(:params_with_filters, options)
    end

    it 'should prefix filters with f_', :options => {:filters => {:foo => true}} do
      expect(@params).to include(:f_foo)
      expect(@params).not_to include(:foo)
    end
    
    it 'should not prefix options', :options => {:foo => true} do
      expect(@params).to include(:foo)
      expect(@params).not_to include(:f_foo)
    end

    it 'should remove filters from options', :options => {:filters => {:foo => true}} do
      expect(@params).not_to include(:filters)
    end
    
    it 'should allow override of default filters and options', :options => {:sort_by => 'awesomeness', :filters => {:l1 => true}} do
      defaults = ChargePoint::API.send(:params_with_filters, {})
      
      expect(defaults[:f_l1]).to eq(false)
      expect(@params[:f_l1]).to eq(true)
      
      expect(defaults[:sort_by]).to eq('distance')
      expect(@params[:sort_by]).to eq('awesomeness')
    end

    it 'should add a fresh timestamp as _' do
      expect(@params).to include(:_)
      expect(@params[:_]).to be_within(2).of(Time.now.to_i)
    end
  end

  context 'when not authenticated' do
    before :all do
      ChargePoint::API.class_variable_set(:@@authenticated, nil)
    end

    it {is_expected.not_to be_authenticated}

    it 'should not allow authenticated methods to attempt to connect' do
      expect {subject.get_charge_spots(1,2)}.to raise_error(RuntimeError, 'method requires authentication')
    end
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

    context '.get_charge_spots' do
      before :each do
        double_agent
        expect_get
      end
      
      after :each do
        undouble_agent
      end
      
      it 'should construct and call the right URL' do
        expect {subject.get_charge_spots(0,0,1)}.not_to raise_error
      end
    end
  end
end
