module Ubiquitously
  module Sphinn
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://sphinn.com/login/")
        form = page.forms.detect { |form| form.form_node["id"] == "thisform" }
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorize!(true)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
      end
    end
  end
end
