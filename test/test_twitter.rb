require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class TwitterTest < ActiveSupport::TestCase
    context "Twitter::Account" do
      setup do
        create_user(:storage => "test/config")
      end
    end

    context "Twitter::Post" do
      setup do
        create_user(:storage => "test/config")

        @title = "Viatropos"
        @description = "Mechanically logging in"
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
        assert @post.save(:twitter)
      end
    end
  end
end
