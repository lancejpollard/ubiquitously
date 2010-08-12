require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class DiggTest < ActiveSupport::TestCase
=begin    
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
=end    
    context "Digg::Post" do
      setup do
        @user = Ubiquitously::User.new(
          :username => "viatropos",
          :cookies_path => "test/cookies.yml"
        )

        @title = "Viatropos"
        @description = "Creativity and Emergence. A personal blog about writing code that the world can leverage."
        @tags = %w(jquery html-5 css3 ajax ruby-on-rails ruby-on-rails-developer ruby-on-rails-examples rails-deployment flex actionscript flash open-source)

        @post = Ubiquitously::Post.new(
          :url => "./test/meta.html",
          :title => @title,
          :description => @description,
          :tags => @tags,
          :user => @user
        )
      end
      
      should "find pre-existent post on digg" do
        @post.url = "http://google.com"
        result = @post.new_record?(:digg)
        assert result
      end
      
      should "create a post" do
        @post.url = "http://apple.com"
        assert @post.save(:digg)
      end
    end
  end
end
