require File.dirname(__FILE__) + '/test_helper.rb'

module Ubiquitously
  class PageTest < ActiveSupport::TestCase
    context "Page" do
      setup do
        @page = Ubiquitously::Page.new(:url => "./test/meta.html")
        @title = "Viatropos"
        @description = "Creativity and Emergence. A personal blog about writing code that the world can leverage."
        @tags = %w(jquery html-5 css3 ajax ruby-on-rails ruby-on-rails-developer ruby-on-rails-examples rails-deployment flex actionscript flash open-source)
      end
      
      should "parse the page" do
        @page.parse
        assert_equal @title, @page.title
        assert_equal @description, @page.description
        assert_equal @tags, @page.tags
      end
    end
  end
end
