module Ubiquitously
  module Chetzit
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://chetzit.com/login/")
        form = page.forms.first
        form["login"] = username
        form["password"] = password
        page = form.submit
        
        authorized?(page.title !~ /^Login/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://chetzit.com/link/add/")
        form = page.forms.detect do |form|
          !form.form_node.css("input[name=security_ls_key]").first.blank?
        end
        
        form.field_with(:name => "blog_id").options.first.select
        
        form["topic_title"] = token[:title]
        form["topic_link_url"] = token[:url]
        # max 500 chars
        form["topic_text"] = token[:description]
        form["topic_tags"] = token[:tags]
        form["submit_topic_publish"] = "Submit New"
        
        page = form.submit(form.buttons.first)
        
        true
      end
    end
  end
end
