require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class DeliciousTest < ActiveSupport::TestCase
    
    context "Delicious::Post" do
      setup do
        create_user
        @post = Ubiquitously::Delicious::Post.new(
          :user => @user,
          :url => "http://github.com",
          :title => "Github",
          :description => "Place to host your code",
          :tags => ["code", "git"]
        )
      end
      
      should "find all delicious posts" do
        puts @post.save.inspect
        assert true
      end
=begin      
      should "create a post" do
        # http://www.Delicious.com/links/buttons.jsp
        assert Ubiquitously::Delicious::Post.create(
          :debug => true,
          :title => "A Title",
          :description => "A Description",
          :tags => ["usability", "ruby", "web services", "open source"],
          :url => "http://example.com/abcdef",
          :user => Ubiquitously::Delicious::Account.new
        )
      end
=end      
    end
  end
end
