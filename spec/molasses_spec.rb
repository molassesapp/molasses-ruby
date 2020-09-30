require 'faraday'
require 'molasses'
require 'webmock/rspec'
responseA = {
  "data": {
      "features": [
          {
              "active": true,
              "description": "foo",
              "key": "FOO_TEST",
              "segments": [
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "alwaysControl",
                      "userConstraints": [
                          {
                              "userParam": "isScaredUser",
                              "operator": "in",
                              "values": "true,maybe",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "alwaysExperiment",
                      "userConstraints": [
                          {
                              "userParam": "isBetaUser",
                              "operator": "equals",
                              "values": "true",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "everyoneElse",
                      "userConstraints": [],
                  },
              ],
          },
      ],
  }, }
responseB = {
  "data": {
      "features": [
          {
              "id": "1",
              "active": true,
              "description": "foo",
              "key": "FOO_TEST",
              "segments": [
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "alwaysControl",
                      "userConstraints": [
                          {
                              "userParam": "isScaredUser",
                              "operator": "nin",
                              "values": "false,maybe",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "alwaysExperiment",
                      "userConstraints": [
                          {
                              "userParam": "isBetaUser",
                              "operator": "doesNotEqual",
                              "values": "false",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "everyoneElse",
                      "userConstraints": [],
                  },
              ],
          },
      ],
  },
}

responseC = {
  "data": {
      "features": [
          {
              "id": "1",
              "active": true,
              "description": "foo",
              "key": "FOO_TEST",
              "segments": [
                  {
                      "percentage": 100,
                      "segmentType": "alwaysControl",
                      "constraint": "all",
                      "userConstraints": [
                          {
                              "userParam": "isScaredUser",
                              "operator": "contains",
                              "values": "scared",
                          },
                          {
                              "userParam": "isDefinitelyScaredUser",
                              "operator": "contains",
                              "values": "scared",
                          },
                          {
                              "userParam": "isMostDefinitelyScaredUser",
                              "operator": "contains",
                              "values": "scared",
                          },
                      ],
                  },
                  {
                      "percentage": 100,
                      "segmentType": "alwaysExperiment",
                      "constraint": "any",
                      "userConstraints": [
                          {
                              "userParam": "isBetaUser",
                              "operator": "doesNotContain",
                              "values": "fal",
                          },
                          {
                              "userParam": "isDefinitelyBetaUser",
                              "operator": "doesNotContain",
                              "values": "fal",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "everyoneElse",
                      "userConstraints": [],
                  },
              ],
          },
      ],
  },
}

responseD = {
  "data": {
      "features": [
          {
              "id": "1",
              "active": true,
              "description": "foo",
              "key": "FOO_TEST",
              "segments": [],
          },
          {
              "id": "2",
              "active": false,
              "description": "foo",
              "key": "FOO_FALSE_TEST",
              "segments": [],
          },
          {
              "id": "3",
              "active": true,
              "description": "foo",
              "key": "FOO_50_PERCENT_TEST",
              "segments": [
                  {
                      "constraint": "all",
                      "segmentType": "everyoneElse",
                      "percentage": 50,
                      "userConstraints": [],
                  },
              ],
          },
          {
              "id": "4",
              "active": true,
              "description": "foo",
              "key": "FOO_0_PERCENT_TEST",
              "segments": [
                  {
                      "constraint": "all",
                      "segmentType": "everyoneElse",
                      "percentage": 0,
                      "userConstraints": [],
                  },
              ],
          },
          {
              "id": "5",
              "active": true,
              "description": "foo",
              "key": "FOO_ID_TEST",
              "segments": [
                  {
                      "constraint": "all",
                      "percentage": 100,
                      "segmentType": "alwaysControl",
                      "userConstraints": [
                          {
                              "userParam": "id",
                              "operator": "equals",
                              "values": "123",
                          },
                      ],
                  },
                  {
                      "constraint": "all",
                      "segmentType": "everyoneElse",
                      "percentage": 100,
                      "userConstraints": [],
                  },
              ],
          },
      ],
  },
}

$client = nil
$conn = nil
$stubs = nil
RSpec.describe Molasses::Client do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { Molasses::Client.new("test_api_key", false) }
  it "can do basic molasses" do
    stub_request(:get, 'https://us-central1-molasses-36bff.cloudfunctions.net/get-features').
      to_return(body:responseA.to_json, headers:  {
        'Content-Type'=>'application/json',
        },)
    expect(client.is_active("FOO_TEST")).to be_truthy
    expect(client.is_active("FOO_TEST", {"foo"=>"foo"})).to be_truthy
    expect(client.is_active("NOT_CHECKOUT")).to be_falsy
    expect(client.is_active("FOO_TEST", {"id"=>"foo", "params"=>{}})).to be_truthy
    expect(client.is_active("FOO_TEST", {"id"=>"food", "params"=>{
                      "isScaredUser"=>"true"}})).to be_falsy
    expect(client.is_active("FOO_TEST", {"id"=>"foodie", "params"=>{
                      "isBetaUser"=>"true"}})).to be_truthy
  end
  it "can do advanced molasses" do
    stub_request(:get, 'https://us-central1-molasses-36bff.cloudfunctions.net/get-features').
      to_return(body:responseB.to_json, headers:  {
        'Content-Type'=>'application/json',
        },)

    expect(client.is_active("FOO_TEST")).to be_truthy
    expect(client.is_active("FOO_TEST", {"foo"=>"foo"})).to be_truthy
    expect(client.is_active("NOT_CHECKOUT")).to be_falsy
    expect(client.is_active("FOO_TEST", {"id"=>"foo", "params"=>{
                              "isBetaUser"=>"false", "isScaredUser"=>"false"}})).to be_truthy
    expect(client.is_active("FOO_TEST", {"id"=>"food", "params"=>{
                              "isScaredUser"=>"true"}})).to be_falsy
    expect(client.is_active("FOO_TEST", {"id"=>"foodie", "params"=>{
                              "isBetaUser"=>"true"}})).to be_truthy
  end
  it "can do even more advanced molasses" do
    stub_request(:get, 'https://us-central1-molasses-36bff.cloudfunctions.net/get-features').
      to_return(body:responseC.to_json, headers:  {
        'Content-Type'=>'application/json',
        },)

    expect(client.is_active("FOO_TEST", {"id"=> "foo", "params" => {
        "isScaredUser"=> "scared",
        "isDefinitelyScaredUser"=> "scared",
        "isMostDefinitelyScaredUser"=> "scared",
    }})).to be_falsy
    expect(client.is_active("FOO_TEST", {"id"=>"food", "params"=>{
                              "isDefinitelyBetaUser"=>"true", "isBetaUser"=>"true"}})).to be_truthy
    expect(client.is_active("FOO_TEST", {"id"=>"foodie", "params"=>{
                              "isBetaUser"=>"true"}})).to be_truthy
  end
end