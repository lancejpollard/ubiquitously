module Ubiquitously
  module DesignBump
    class Account < Ubiquitously::Service::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://designbump.com/login")
        form = page.forms.detect { |form| form.form_node["id"] == "user-login-form" }
        form["name"] = username
        form["pass"] = password
        page = form.submit
        
        @logged_in = page.uri != "http://designbump.com/user?destination=login"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    # drupal
    class Post < Ubiquitously::Service::Post
      
      def tokenize
        super.merge(:tags => tags.taggify(" ", :quote => true))
      end
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://designbump.com/submit")
        form = page.form_with(:action => "/submit")
        
        form["url"] = token[:url]
        form["title"] = token[:title]
        form["body"] = token[:description]
        form.field_with(:name => "taxonomy[1]").options.each do |option|
          option.select if option.value.to_s == "21"
        end
        form["taxonomy[tags][2]"] = token[:tags]
        form["op"] = "Save"
        
        page = form.submit
        
        true
      end
    end
  end
end
