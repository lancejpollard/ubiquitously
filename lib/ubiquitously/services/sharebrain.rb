module Ubiquitously
  module Sharebrain
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://digzign.com/login")
        form = page.form_with(:name => "loginform")
        form["username"] = username
        form["password"] = password
        page = form.submit
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("")
      end
    end
  end
end
