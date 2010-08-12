require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class DzoneTest < ActiveSupport::TestCase
=begin    
    context "Dzone::Account" do
      setup do
        @user = Ubiquitously::Dzone::Account.new
      end
      
      context "login" do
        should "raise informative error if invalid password" do
          @user.password = "bad password"
          assert_raises(Ubiquitously::AuthenticationError) do
            @user.login
          end
        end
      end
    end
=end
    context "Dzone::Post" do
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
        @post.url = "http://www.zhione.com/security/understanding-network-security-in-plain-english/"
        assert @post.save(:dzone)
      end
    end
  end
end
