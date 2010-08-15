module Ubiquitously
  module Shoutwire
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://shoutwire.com/login")
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$Username"] = username
        form["ctl06$Password"] = password
        page = form.submit
        
        authorize!(page.url.downcase != "http://shoutwire.com/login")
      end
    end
    
    class Post < Ubiquitously::Service::Post      
      def create
        page = agent.get("http://shoutwire.com/submit")
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$txtLink"] = token[:url]
        page = form.submit
        
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$txtTitle"] = token[:title]
        form["ctl06$txtDescription"] = token[:description]
        #page = form.submit
        
        # has a captcha, not done
        unless debug?
          page = form.submit
        end
      end
    end
  end
end
