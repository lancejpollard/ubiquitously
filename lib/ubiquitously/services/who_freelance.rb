module Ubiquitously
  module WhoFreelance
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://digzign.com/login")
        form = page.form_with(:name => "loginform")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = !(page.title =~ /Like Digg/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def save(options = {})
        return false if !valid?
        
        authorize
        
        page = agent.get("")
      end
    end
  end
end
