require 'rails_helper'

RSpec.describe "CtRegisterMicroservice::ControlTower register" do
  before(:all) do
    CtRegisterMicroservice.configure do |config|
      config.ct_url = 'http://control-tower.com'
      config.url = 'http://my-microservice-url.com'
      config.ct_token = 'token'
      config.swagger = __dir__ + '/../mocks/mock-swagger.json'
      config.name = 'Test'
    end
  end
  it "registration with Control Tower down throws an exception" do
    request_url = "http://control-tower.com/api/v1/microservice"
    request_content = {
      body: {
        name: 'Test',
        url: 'http://my-microservice-url.com',
        active: true
      }
    }

    stub_request(:post, request_url).with(request_content).to_return(status: 404, body: '{"errors":[{"status":404,"detail":"Control Tower is down"}]}').times(1)

    @service = CtRegisterMicroservice::ControlTower.new()

    expect { @service.register_service() }.to raise_error(CtRegisterMicroservice::NotFoundError, 'Control Tower is down')
  end

  it "registers services in Control Tower" do
    @service = CtRegisterMicroservice::ControlTower.new()

    request_url = "http://control-tower.com/api/v1/microservice"
    request_content = {
      body: {
        name: 'Test',
        url: 'http://my-microservice-url.com',
        active: true
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    }

    stub_request(:post, request_url).with(request_content).to_return(status: 200, body: '{}', headers: {}).times(1)

    @service.register_service()

    expect(a_request(:post, request_url).with(request_content)).to have_been_made.once
  end

  after(:all) do
    CtRegisterMicroservice.config = nil
  end

end
