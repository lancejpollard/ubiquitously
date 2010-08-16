require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class FavesTest < ActiveSupport::TestCase
    context "Faves::Account" do
      setup do
        create_user(:storage => "test/config")
      end
      
      context "login" do
        
        should "login successfully if valid credentials" do
          assert_equal true, @user.login(:faves)
        end
      end
    end
    context "Faves::Post" do
      setup do
        create_user(:storage => "test/config")

        @title = "Viatropos"
        @description = "Mechanically logging in"
        @tags = %w(ubiquitous)
        
        @post = Ubiquitously::Post.new(
          :url => "http://twitter.com/",
          :title => @title,
          :description => @description,
          :tags => @tags,
          :user => @user
        )
      end
      
      should "create a post" do
        assert @post.save(:faves)
      end
    end

  end
end
