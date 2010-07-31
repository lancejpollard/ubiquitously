require File.dirname(__FILE__) + '/test_helper.rb'
require 'restclient'
module Ubiquitously
  class FavesTest < ActiveSupport::TestCase
    context "Faves::User" do
      setup do
        @user = Ubiquitously::Faves::User.new
      end
      
      context "login" do
        should "raise informative error if invalid password" do
          @user.password = "bad password"
          assert_raises(Ubiquitously::AuthenticationError) do
            @user.login
          end
        end
        
        should "login successfully if valid credentials" do
          assert_equal true, @user.login
        end
      end
    end
=begin    
    context "Faves::Post" do
      setup do
        @post = Ubiquitously::Faves::Post.new(
          :debug => true,
          :title => "A Title",
          :description => "A Description",
          :tags => ["usability", "ruby", "web services", "open source"],
          :url => "http://example.com/abcdef",
          :user => Ubiquitously::Faves::User.new
        )
      end
      
      should "create a post" do
        assert @post.save
      end
    end
=end    
  end
end
