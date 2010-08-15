module Ubiquitously
  module CodeProject
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.codeproject.com/script/Articles/Submit.aspx")
        form = page.form_with(:name => "subForm")
        form["Email"] = email
        form["Password"] = password
        page = form.submit
        
        authorized?(page.title =~ /Article Submission/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://www.codeproject.com/script/Articles/SubmitStep1.aspx")
      end
    end
  end
end
