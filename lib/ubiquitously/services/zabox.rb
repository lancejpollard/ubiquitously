module Ubiquitously
  module Zabox
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.zabox.net/login.php")
        form = page.forms.detect { |form| form.form_node["id"] == "thisform" }
        form["username"] = username
        form["password"] = password
        form.checkboxes.first.check
        page = form.submit
        
        @logged_in = (page.parser.css("form .error").text =~ /ERROR/i).nil?
        
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
        
        page = agent.get("http://www.zabox.net/submit")
      end
    end
  end
end
