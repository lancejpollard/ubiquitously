require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class RedditTest < ActiveSupport::TestCase
    context "Reddit::Account" do
      setup do
        @user = Ubiquitously::Reddit::Account.new
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
    
    context "Reddit::Post" do
      setup do
        @post = Ubiquitously::Reddit::Post.new
      end
    end
  end
end
