require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class RedditTest < ActiveSupport::TestCase
=begin    
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
=end    
    context "Reddit::Post" do
      setup do
        @user = Ubiquitously::User.new(
          :username => "viatropos",
          :cookies_path => "test/cookies.yml"
        )

        @title = "Using Redis on Heroku"
        @description = "The only javascript framework you'll need.  Well, if you need Object Oriented JS, you'll have to do a little initial setup."
        @tags = %w(javascript, frameworks, jquery)

        @post = Ubiquitously::Post.new(
          :url => "./test/meta.html",
          :title => @title,
          :description => @description,
          :tags => @tags,
          :categories => ["web-design"],
          :user => @user
        )
      end
  
      should "create a post" do
        @post.url = "http://jeffkreeftmeijer.com/2010/things-i-learned-from-my-node.js-experiment/"
        assert @post.save(:reddit)
      end
    end
  end
end
