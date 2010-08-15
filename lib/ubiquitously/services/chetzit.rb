module Ubiquitously
  module Chetzit
    class Account < Ubiquitously::Service::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://chetzit.com/login/")
        form = page.forms.first
        form["login"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /^Login/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
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
