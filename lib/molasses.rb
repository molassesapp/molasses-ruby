require "logger"
require "workers"
require "faraday"
require "json"
require "zlib"

module Molasses
  class Client
    def initialize(api_key, opts = {})
      @api_key = api_key
      @send_events = opts[:auto_send_events] || false
      @base_url = opts[:base_url] || "https://sdk.molasses.app/v1"
      @logger = opts[:logger] || get_default_logger
      @conn = Faraday.new(
        url: @base_url,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@api_key}",
        },
      )
      @feature_cache = {}
      @initialized = {}

      fetch_features
      @timer = Workers::PeriodicTimer.new(15) do
        fetch_features
      end
    end

    def is_active(key, user = {})
      unless @initialized
        return false
      end

      if @feature_cache.include?(key)
        feature = @feature_cache[key]
        result = user_active(feature, user)
        if @send_events && user && user.include?("id")
          send_event({
            "event" => "experiment_started",
            "tags" => user["params"],
            "userId" => user["id"],
            "featureId" => feature["id"],
            "featureName" => key,
            "testType" => result ? "experiment" : "control",
          })
        end
        return result
      else
        @logger.info "Warning - feature flag #{key} not set in environment"
        return false
      end
    end

    def stop
      @timer.cancel
    end

    def experiment_started(key, user = nil, additional_details = {})
      if !@initialized || user == nil || !user.include?("id")
        return false
      end
      unless @feature_cache.include?(key)
        @logger.info "Warning - feature flag #{key} not set in environment"
        return false
      end
      feature = @feature_cache[key]
      result = is_active(feature, user)
      send_event({
        "event" => "experiment_started",
        "tags" => user.include?("params") ? user["params"].merge(additional_details) : additional_details,
        "userId" => user["id"],
        "featureId" => feature["id"],
        "featureName" => key,
        "testType" => result ? "experiment" : "control",
      })
    end

    def experiment_success(key, user = nil, additional_details = {})
      if !@initialized || user == nil || !user.include?("id")
        return false
      end
      unless @feature_cache.include?(key)
        @logger.info "Warning - feature flag #{key} not set in environment"
        return false
      end
      feature = @feature_cache[key]
      result = is_active(feature, user)
      send_event({
        "event" => "experiment_success",
        "tags" => user.include?("params") ? user["params"].merge(additional_details) : additional_details,
        "userId" => user["id"],
        "featureId" => feature["id"],
        "featureName" => key,
        "testType" => result ? "experiment" : "control",
      })
    end

    def track(key, user = nil, additional_details = {})
      if user == nil || !user.include?("id")
        return false
      end
      send_event({
        "event" => key,
        "tags" => user.include?("params") ? user["params"].merge(additional_details) : additional_details,
        "userId" => user["id"],
      })
    end

    private

    def user_active(feature, user)
      unless feature.include?("active")
        return false
      end

      unless user && user.include?("id")
        return true
      end

      segment_map = {}
      for feature_segment in feature["segments"]
        segment_type = feature_segment["segmentType"]
        segment_map[segment_type] = feature_segment
      end

      if segment_map.include?("alwaysControl") and in_segment(user, segment_map["alwaysControl"])
        return false
      end
      if segment_map.include?("alwaysExperiment") and in_segment(user, segment_map["alwaysExperiment"])
        return true
      end

      return user_percentage(user["id"], segment_map["everyoneElse"]["percentage"])
    end

    def user_percentage(id = "", percentage = 0)
      if percentage == 100
        return true
      end

      if percentage == 0
        return false
      end

      c = Zlib.crc32(id)
      v = (c % 100).abs
      return v < percentage
    end

    def in_segment(user, segment_map)
      user_constraints = segment_map["userConstraints"]
      constraints_length = user_constraints.length
      constraints_to_be_met = segment_map["constraint"] == "any" ? 1 : constraints_length
      constraints_met = 0

      for constraint in user_constraints
        param = constraint["userParam"]
        param_exists = user["params"].include?(param)
        user_value = nil
        if param_exists
          user_value = user["params"][param]
        end

        if param == "id"
          param_exists = true
          user_value = user["id"]
        end

        if meets_constraint(user_value, param_exists, constraint)
          constraints_met = constraints_met + 1
        end
      end
      return constraints_met >= constraints_to_be_met
    end

    def parse_number(user_value)
      case user_value
      when Numeric
        return user_value
      when TrueClass
        return 1
      when FalseClass
        return 0
      when String
        return user_value.to_f
      end
    end

    def parse_bool(user_value)
      case user_value
      when Numeric
        return user_value == 1
      when TrueClass, FalseClass
        return user_value
      when String
        return user_value == "true"
      end
    end

    def meets_constraint(user_value, param_exists, constraint)
      operator = constraint["operator"]
      if param_exists == false
        return false
      end

      constraint_value = constraint["values"]
      case constraint["userParamType"]
      when "number"
        user_value = parse_number(user_value)
        constraint_value = parse_number(constraint_value)
      when "boolean"
        user_value = parse_bool(user_value)
        constraint_value = parse_bool(constraint_value)
      else
        user_value = user_value.to_s
      end

      case operator
      when "in"
        list_values = constraint_value.split(",")
        return list_values.include? user_value
      when "nin"
        list_values = constraint_value.split(",")
        return !list_values.include?(user_value)
      when "lt"
        return user_value < constraint_value
      when "lte"
        return user_value <= constraint_value
      when "gt"
        return user_value > constraint_value
      when "gte"
        return user_value >= constraint_value
      when "equals"
        return user_value == constraint_value
      when "doesNotEqual"
        return user_value != constraint_value
      when "contains"
        return constraint_value.include?(user_value)
      when "doesNotContain"
        return !constraint_value.include?(user_value)
      else
        return false
      end
    end

    def send_event(event_options)
      @conn.post("analytics", event_options.to_json)
    end

    def fetch_features()
      response = @conn.get("features")
      if response.status == 200
        data = JSON.parse(response.body)
        if data.include?("data") and data["data"].include?("features")
          features = data["data"]["features"]
          for feature in features
            @feature_cache[feature["key"]] = feature
          end
          unless @initialized
            @logger.info "Molasses - connected and initialized"
          end
          @initialized = true
        end
      else
        @logger.info "Molasses - #{response.status} - #{response.body}"
      end
    end

    def get_default_logger
      if defined?(Rails) && Rails.respond_to?(:logger)
        Rails.logger
      else
        log = ::Logger.new(STDOUT)
        log.level = ::Logger::WARN
        log
      end
    end
  end
end
