require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class StumbleUponTest < ActiveSupport::TestCase
    context "StumbleUpon::User" do
      setup do
        @user = Ubiquitously::StumbleUpon::User.new
      end
      
      context "login" do
        should "raise informative error if invalid password" do
          @user.password = "bad password"
          assert_raises(Ubiquitously::AuthenticationError) do
            @user.login
          end
          assert_equal false, @user.logged_in?
        end
        
        should "login successfully if valid credentials" do
          assert_equal true, @user.login
          assert_equal true, @user.logged_in?
        end
      end
    end
    
    context "StumbleUpon::Post" do
      setup do
        @post = Ubiquitously::StumbleUpon::Post.new
      end
    end
  end
end
