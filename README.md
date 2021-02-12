<p align="center">
<img src="https://raw.githubusercontent.com/molassesapp/molasses-go/main/logo.png" style="margin: 0px auto;" width="200"/></p>

<h1 align="center">Molasses-Ruby</h1>

A Ruby SDK for Molasses. It allows you to evaluate user's status for a feature. It also helps simplify logging events for A/B testing.

Molasses uses polling to check if you have updated features. Once initialized, it takes microseconds to evaluate if a user is active.

## Install

```
gem install molasses

bundle add molasses
```

## Usage

### Initialization

Start by initializing the client with an `APIKey`. This begins the polling for any feature updates. The updates happen every 15 seconds.

```ruby
require 'molasses'

client = Molasses::Client.new("test_api_key")

```

If you decide you want to auto track experiments being viewed (experiment started events) you can turn that on by setting the `:auto_send_events` field to `true`

```go
client = Molasses::Client.new("test_api_key", {
  :auto_send_events => true
})

```

### Check if feature is active

You can call `is_active` with the key name and optionally a user's information. The `id` field is used to determine whether a user is part of a percentage of users. If you have other constraints based on user params you can pass those in the `params` field.

```ruby
 client.is_active("FOO_TEST", {
   "id"=>"foo",
   "params"=>{
     "isBetaUser"=>"false",
     "isScaredUser"=>"false"
    }
 })

```

You can check if a feature is active for a user who is anonymous by just calling `isActive` with the key. You won't be able to do percentage roll outs or track that user's behavior.

```ruby
client.is_active("TEST_FEATURE_FOR_USER")
```

### Tracking and Experiments

To track any analytics event you can call `track`. experiment_success takes the event's name,the user, and any additional parameters for the event.

```ruby
client.track("Button Clicked", {
   "id"=>"foo",
   "params"=>{
     "isBetaUser"=>"false",
     "isScaredUser"=>"false"
    }
 }, {
		"version": "v2.3.0"
	},)
```

To track whether an experiment was started you can call `experiment_started`. experiment_started takes the feature's name,the user, and any additional parameters for the event.

```ruby
client.experiment_started("GOOGLE_SSO", {
   "id"=>"foo",
   "params"=>{
     "isBetaUser"=>"false",
     "isScaredUser"=>"false"
    }
 }, {
		"version": "v2.3.0"
	},)
```

To track whether an experiment was successful you can call `experiment_success`. experiment_success takes the feature's name,the user, and any additional parameters for the event.

```ruby
client.experiment_success("GOOGLE_SSO", {
   "id"=>"foo",
   "params"=>{
     "isBetaUser"=>"false",
     "isScaredUser"=>"false"
    }
 }, {
		"version": "v2.3.0"
	},)
```

## Example

```ruby
require 'molasses'

client = Molasses::Client.new("test_api_key")

if client.is_active('NEW_CHECKOUT') {
  puts "we are a go"
else
  puts "we are a no go"
end
foo_test = client.is_active("FOO_TEST", {
  "id"=>"foo",
  "params"=>{
    "isBetaUser"=>"false",
    "isScaredUser"=>"false"
  }
})
if foo_test
  puts "we are a go"
else
  puts "we are a no go"
end
```
