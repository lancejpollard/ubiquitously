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

Ubiquitously.configure("test/config/secrets.yml")
Passport.configure("test/config/tokens.yml")

ActiveSupport::TestCase.class_eval do
  def create_user(options)
    @user = Ubiquitously::User.new(options.merge(:username => "viatropos"))
  end
end
