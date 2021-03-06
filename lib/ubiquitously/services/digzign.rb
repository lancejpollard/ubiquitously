module Ubiquitously
  module Digzign
    class Account < Ubiquitously::Service::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://digzign.com/login")
        form = page.form_with(:name => "loginform")
        form["username"] = username
        form["password"] = password
        page = form.submit
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def save(options = {})
        return false if !valid?
        
        authorize
        
        page = agent.get("")
      end
    end
  end
end
