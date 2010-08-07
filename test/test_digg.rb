require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class DiggTest < ActiveSupport::TestCase
    context "Digg::Account" do
      setup do
        @user = Ubiquitously::Digg::Account.new
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
    context "Digg::Post" do
      setup do
        @post = Ubiquitously::Digg::Post.new(
          :debug => true,
          :title => "A Title",
          :description => "A Description",
          :tags => ["usability", "ruby", "web services", "open source"],
          :url => "http://example.com/abcdef",
          :user => Ubiquitously::Digg::Account.new
        )
      end
      
      should "create a post" do
        assert @post.save
      end
    end
=end    
  end
end
