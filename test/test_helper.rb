require "rubygems"
require 'active_support'
require "ruby-debug"
gem 'test-unit'
require "test/unit"
require 'active_support'
require 'active_support/test_case'
require 'shoulda'
require 'rr'

require File.dirname(__FILE__) + '/../lib/ubiquitously'

Ubiquitously.configure("test/config.yml")