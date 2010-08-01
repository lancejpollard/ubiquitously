require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class YahooBuzzTest < ActiveSupport::TestCase
    context "YahooBuzz::User" do
      setup do
        @user = Ubiquitously::YahooBuzz::User.new
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
    
    context "YahooBuzz::Post" do
      setup do
        @post = Ubiquitously::YahooBuzz::Post.new(
          :title => "A Title",
          :description => "A Description",
          :tags => ["usability", "ruby", "web services", "open source"],
          :url => "http://example.com/abcdef",
          :user => Ubiquitously::YahooBuzz::User.new
        )
      end
      
      should "create a post" do
        assert @post.save(:debug => true)
      end
    end
  end
end
