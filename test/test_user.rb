require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class UserTest < ActiveSupport::TestCase
    
    context "User" do
      setup do
        @user = Ubiquitously::User.new(
          :username => "viatropos",
          :cookies_path => "test/cookies.yml"
        )
      end
      
      should "save cookies for user" do
        @user.login(:dzone, :newsvine)
        @user.accounts.each do |account|
          assert_equal true, account.logged_in?
        end
      end
    end
  end
end
