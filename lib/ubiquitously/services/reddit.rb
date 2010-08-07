module Ubiquitously
  module Reddit
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.reddit.com/")
        form = page.form_with(:action => "http://www.reddit.com/post/login")
        form["user"]   = username
        form["passwd"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /login or register/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title
      
      def save(options = {})
        return false unless valid?
        
        user.login
        
        page = agent.get("http://www.reddit.com/submit")
        form = page.forms.detect {|form| form.form_node["id"] == "newlink"}
        form["title"] = title
        form["url"]   = url
        form["id"] = "#newlink"
        if page.body =~ /modhash\:\s+'([^']+)'/
          form["uh"] = $1
        end
        form["renderstyle"] = "html"
        form["kind"] = "link"
        
        form.action = "http://www.reddit.com/api/submit"
        headers = {
          "X-Requested-With" => "XMLHttpRequest"
        }
        unless options[:debug] == true
          page = form.submit(nil, headers)
        end
      end
    end
  end
end
