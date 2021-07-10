require "simplecov"
SimpleCov.start
require "faraday"
require "molasses"
require "webmock/rspec"
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
  },
}
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
        "id": "2",
        "active": true,
        "description": "bar",
        "key": "NUMBERS_BOOLS",
        "segments": [
          {
            "percentage": 100,
            "segmentType": "alwaysControl",
            "constraint": "all",
            "userConstraints": [
              {
                "userParam": "lt",
                "userParamType": "number",
                "operator": "lt",
                "values": 12,
              },
              {
                "userParam": "lte",
                "userParamType": "number",
                "operator": "lte",
                "values": 12,
              },
              {
                "userParam": "gt",
                "userParamType": "number",
                "operator": "gt",
                "values": 12,
              },
              {
                "userParam": "gte",
                "userParamType": "number",
                "operator": "gte",
                "values": 12,
              },
              {
                "userParam": "equals",
                "userParamType": "number",
                "operator": "equals",
                "values": 12,
              },
              {
                "userParam": "doesNotEqual",
                "userParamType": "number",
                "operator": "doesNotEqual",
                "values": 12,
              },
              {
                "userParam": "equalsBool",
                "userParamType": "boolean",
                "operator": "equals",
                "values": true,
              },
              {
                "userParam": "doesNotEqualBool",
                "userParamType": "boolean",
                "operator": "doesNotEqual",
                "values": false,
              },

            ],

          },
          {
            "constraint": "all",
            "percentage": 50,
            "segmentType": "everyoneElse",
            "userConstraints": [],
          },
        ],
      },
      {
        "id": "4",
        "active": true,
        "description": "bar",
        "key": "semver",
        "segments": [
          {
            "percentage": 100,
            "segmentType": "alwaysExperiment",
            "constraint": "any",
            "userConstraints": [
              {
                "userParam": "lt",
                "userParamType": "semver",
                "operator": "lt",
                "values": "1.2.0",
              },
              {
                "userParam": "lte",
                "userParamType": "semver",
                "operator": "lte",
                "values": "1.2.0",
              },
              {
                "userParam": "gt",
                "userParamType": "semver",
                "operator": "gt",
                "values": "1.2.0",
              },
              {
                "userParam": "gte",
                "userParamType": "semver",
                "operator": "gte",
                "values": "1.2.0",
              },
              {
                "userParam": "equals",
                "userParamType": "semver",
                "operator": "equals",
                "values": "1.2.0",
              },
              {
                "userParam": "doesNotEqual",
                "userParamType": "semver",
                "operator": "doesNotEqual",
                "values": "1.2.0",
              },

            ],

          },
          {
            "constraint": "all",
            "percentage": 0,
            "segmentType": "everyoneElse",
            "userConstraints": [],
          },
        ],
      },
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
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { Molasses::Client.new("test_api_key") }
  it "can do basic molasses" do
    stub_request(:get, "https://sdk.molasses.app/v1/features").
      to_return(body: responseA.to_json, headers: {
                  "Content-Type" => "application/json",
                })
    expect(client.is_active("FOO_TEST")).to be_truthy
    expect(client.is_active("FOO_TEST", { "foo" => "foo" })).to be_truthy
    expect(client.is_active("NOT_CHECKOUT")).to be_falsy
    expect(client.is_active("FOO_TEST", { "id" => "foo", "params" => {} })).to be_truthy
    expect(client.is_active("FOO_TEST", { "id" => "food", "params" => {
      "isScaredUser" => "true",
    } })).to be_falsy
    expect(client.is_active("FOO_TEST", { "id" => "foodie", "params" => {
      "isBetaUser" => "true",
    } })).to be_truthy
  end
  it "can do advanced molasses" do
    stub_request(:get, "https://sdk.molasses.app/v1/features").
      to_return(body: responseB.to_json, headers: {
                  "Content-Type" => "application/json",
                })

    expect(client.is_active("FOO_TEST")).to be_truthy
    expect(client.is_active("FOO_TEST", { "foo" => "foo" })).to be_truthy
    expect(client.is_active("NOT_CHECKOUT")).to be_falsy
    expect(client.is_active("FOO_TEST", { "id" => "foo", "params" => {
      "isBetaUser" => "false", "isScaredUser" => "false",
    } })).to be_truthy
    expect(client.is_active("FOO_TEST", { "id" => "food", "params" => {
      "isScaredUser" => "true",
    } })).to be_falsy
    expect(client.is_active("FOO_TEST", { "id" => "foodie", "params" => {
      "isBetaUser" => "true",
    } })).to be_truthy
  end
  it "can do even more advanced molasses" do
    stub_request(:get, "https://sdk.molasses.app/v1/features").
      to_return(body: responseC.to_json, headers: {
                  "Content-Type" => "application/json",
                })
    stub_request(:post, "https://sdk.molasses.app/v1/analytics").
      to_return(status: 200, body: "", headers: {})
    expect(client.is_active("FOO_TEST", { "id" => "foo", "params" => {
      "isScaredUser" => "scared",
      "isDefinitelyScaredUser" => "scared",
      "isMostDefinitelyScaredUser" => "scared",
    } })).to be_falsy
    expect(client.is_active("FOO_TEST", { "id" => "food", "params" => {
      "isDefinitelyBetaUser" => "true", "isBetaUser" => "true",
    } })).to be_truthy
    expect(client.is_active("FOO_TEST", { "id" => "foodie", "params" => {
      "isBetaUser" => "true",
    } })).to be_truthy

    expect(client.is_active("NUMBERS_BOOLS", {
      "id" => "12341",
      "params" => {
        "lt" => true,
        "lte" => "12",
        "gt" => 14,
        "gte" => 12,
        "equals" => 12,
        "doesNotEqual" => false,
        "equalsBool" => true,
        "doesNotEqualBool" => "true",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => "1.1",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => "1.2.0",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "gt" => "1.3.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "gt" => "1.2.0",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lte" => "1.1",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lte" => "1.2.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lte" => "1.3.0",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "gte" => "1.3.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "gte" => "1.2.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "gte" => "0.1.0",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "equals" => "1.2.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "equals" => "1.3.0",
      },
    })).to be_falsy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "doesNotEqual" => "1.3.0",
      },
    })).to be_truthy

    expect(client.is_active("semver", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "doesNotEqual" => "1.2.0",
      },
    })).to be_falsy

    expect(client.is_active("NUMBERS_BOOLS", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => true,
        "lte" => "12",
        "gt" => 14,
        "gte" => 12,
        "equals" => 12,
        "doesNotEqual" => false,
        "equalsBool" => 0,
        "doesNotEqualBool" => "true",
      },
    })).to be_truthy
    expect(client.experiment_started("NUMBERS_BOOLS", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => true,
        "lte" => "12",
        "gt" => 14,
        "gte" => 12,
        "equals" => 12,
        "doesNotEqual" => false,
        "equalsBool" => 0,
        "doesNotEqualBool" => "true",
      },
    }))
    expect(client.experiment_started("Clicked button", {
      "id" => "123444", # v
    }))
    expect(client.track("Clicked button", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => true,
        "lte" => "12",
        "gt" => 14,
        "gte" => 12,
        "equals" => 12,
        "doesNotEqual" => false,
        "equalsBool" => 0,
        "doesNotEqualBool" => "true",
      },
    }))
    expect(client.experiment_success("NUMBERS_BOOLS", {
      "id" => "123444", # valid crc32 percentage
      "params" => {
        "lt" => true,
        "lte" => "12",
        "gt" => 14,
        "gte" => 12,
        "equals" => 12,
        "doesNotEqual" => false,
        "equalsBool" => 0,
        "doesNotEqualBool" => "true",
      },
    }))
  end
end
