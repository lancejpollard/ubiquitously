module Ubiquitously
  module ScriptAndStyle
    class Account < Ubiquitously::Service::Account
      def login
        return true # no login
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://scriptandstyle.com/submit")
        form = page.form_with(:name => "tdomf_form1")
        
        form["whoami_name"] = user.name
        form["whoami_email"] = user.email
        form["content_title"] = title
        form["whoami_webpage"] = url
        form["content_content"] = description
        
        page = form.submit
        
        true
      end
    end
  end
end
