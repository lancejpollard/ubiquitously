module Ubiquitously
  module Zabox
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.zabox.net/login.php")
        form = page.forms.detect { |form| form.form_node["id"] == "thisform" }
        form["username"] = username
        form["password"] = password
        form.checkboxes.first.check
        page = form.submit
        
        authorize!(page.parser.css("form .error").text !~ /ERROR/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://www.zabox.net/submit")
      end
    end
  end
end
