#!/usr/bin/env ruby

require_relative '../lib/molasses'

client = Molasses::Client.new("test_api_key")

puts client.is_active('NEW_CHECKOUT')

puts client.is_active('NOT_NEW_CHECKOUT')

