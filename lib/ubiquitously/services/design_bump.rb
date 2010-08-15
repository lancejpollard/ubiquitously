module Ubiquitously
  module DesignBump
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://designbump.com/login")
        form = page.forms.detect { |form| form.form_node["id"] == "user-login-form" }
        form["name"] = username
        form["pass"] = password
        page = form.submit
        
        authorize!(page.uri != "http://designbump.com/user?destination=login")
      end
    end
    
    # drupal
    class Post < Ubiquitously::Service::Post
      
      def tokenize
        super.merge(:tags => tags.taggify(" ", :quote => true))
      end
      
      def create
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
