module Ubiquitously
  module DesignrFix
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://service.com/login")
        form = page.form_with(:name => "loginform")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorized?(page.title =~ /Some title/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("")
      end
    end
  end
end
