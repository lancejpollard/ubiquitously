require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class PropellerTest < ActiveSupport::TestCase
    context "Propeller::User" do
      setup do
        @user = Ubiquitously::Propeller::User.new
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
      
      context "Propeller::Post" do
        setup do
          @post = Ubiquitously::Propeller::Post.new(
            :debug => true,
            :title => "A Title",
            :description => "A Description",
            :tags => ["usability", "ruby", "web services", "open source"],
            :url => "http://example.com/abcdef"
          )
        end
        
        should "create a post" do
          assert @post.save(:debug => true)
        end
      end
    end
    
  end
end
