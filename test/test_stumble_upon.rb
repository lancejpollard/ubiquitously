require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class StumbleUponTest < ActiveSupport::TestCase
    context "StumbleUpon::Account" do
      setup do
        @user = Ubiquitously::StumbleUpon::Account.new
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
        @user = Ubiquitously::User.new(
          :username => "viatropos",
          :cookies_path => "test/cookies.yml"
        )

        @title = "jQuery"
        @description = "The only javascript framework you'll need.  Well, if you need Object Oriented JS, you'll have to do a little initial setup."
        @tags = %w(javascript, frameworks, jquery)

        @post = Ubiquitously::Post.new(
          :url => "./test/meta.html",
          :title => @title,
          :description => @description,
          :tags => @tags,
          :user => @user
        )
      end
      
      should "create a post" do
        @post.url = "http://jquery.com"
        assert @post.save(:stumble_upon)
      end
    end
  end
end
