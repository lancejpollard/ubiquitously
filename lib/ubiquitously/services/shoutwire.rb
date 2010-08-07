module Ubiquitously
  module Shoutwire
    class Account < Ubiquitously::Base::Account
      def login
        page = agent.get("http://shoutwire.com/login")
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$Username"] = username
        form["ctl06$Password"] = password
        page = form.submit
        
        @logged_in = (page.url.downcase == "http://shoutwire.com/login").nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save
        return false unless valid?

        user.login
        
        page = agent.get("http://shoutwire.com/submit")
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$txtLink"] = url
        page = form.submit
        
        form = page.form_with(:name => "TemplateMainForm")
        form["ctl06$txtTitle"] = title
        form["ctl06$txtDescription"] = description
        #page = form.submit
        
        # has a captcha, not done
        unless options[:debug] == true
          page = form.submit
        end
      end
    end
  end
end
