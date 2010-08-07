require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class DzoneTest < ActiveSupport::TestCase
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
    
    context "Dzone::Post" do
      setup do
        @post = Ubiquitously::Dzone::Post.new
      end
      
      should "raise error if post exists already" do
        assert_raises(Ubiquitously::DuplicateError) do
          Ubiquitously::Dzone::Post.new_record?("http://www.google.com", true)
        end
      end
      
      should "create a post" do
        # http://www.dzone.com/links/buttons.jsp
        assert Ubiquitously::Dzone::Post.create(
          :debug => true,
          :title => "A Title",
          :description => "A Description",
          :tags => ["usability", "ruby", "web services", "open source"],
          :url => "http://example.com/abcdef"
        )
      end
    end
  end
end
