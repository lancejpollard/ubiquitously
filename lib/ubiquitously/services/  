module Ubiquitously
  module Sphinn
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://sphinn.com/login/")
        form = page.forms.detect { |form| form.form_node["id"] == "thisform" }
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = true#(page.title =~ /Login Error/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
      end
    end
  end
end
