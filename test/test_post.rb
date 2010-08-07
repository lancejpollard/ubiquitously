require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class PostTest < ActiveSupport::TestCase
    context "Post" do
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
      
      should "parse the page" do
        @page = @post.page
        assert_equal @title, @page.title
        assert_equal @description, @page.description
        assert_equal @tags, @page.tags
      end
      
      should "respond to dynamic methods" do
        assert_equal true, @post.respond_to?(:dzone?)
        assert_equal true, @post.respond_to?(:digg?)
      end
      
      should "dynamically create post service objects" do
        assert_kind_of Ubiquitously::Dzone::Post, @post.dzone
        assert_equal true, @post.dzone.new_record?
        assert_equal false, @post.dzone? # it's a new record
      end
      
      should "be able to create the post" do
        @post.faves.save(:debug => true)
        assert @post.faves.valid?
      end
      
      should "be able to find posts" do
        result = @post.faves.find
        assert result
        assert @post.faves.new_record?
      end
    end
  end
end
