module Ubiquitously
  module CodeProject
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.codeproject.com/script/Articles/Submit.aspx")
        form = page.form_with(:name => "subForm")
        form["Email"] = email
        form["Password"] = password
        page = form.submit
        
        @logged_in = !(page.title =~ /Article Submission/i).nil?
        
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
        
        page = agent.get("http://www.codeproject.com/script/Articles/SubmitStep1.aspx")
      end
    end
  end
end
