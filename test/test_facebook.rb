require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class FacebookTest < ActiveSupport::TestCase
    context "Facebook::Account" do
      setup do
        create_user(:storage => "test/config")
      end
      
      context "login" do
        should "login successfully if valid credentials" do
          assert_equal true, @user.login(:facebook)
        end
      end
    end

    context "Facebook::Post" do
      setup do
        create_user(:storage => "test/config")

        @title = "Viatropos"
        @description = "Facebook posting ubiquitously"
        @tags = %w(ubiquitous)

        @post = Ubiquitously::Post.new(
          :url => "./test/meta.html",
          :title => @title,
          :description => @description,
          :tags => @tags,
          :user => @user
        )
      end
      
      should "create a post" do
        assert @post.save(:facebook)
      end
    end
    
  end
end
