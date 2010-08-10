module Ubiquitously
  module Webdev5
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://webdev5.com/user/login")
        form = page.forms.detect {|form| form.form_node["id"] == "user-login"}
        form["name"] = username
        form["pass"] = password
        page = form.submit
        
        @logged_in = (page.title.strip =~ /^User account/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      submit_to "http://webdev5.com/submit?url=:url&title=:title&body=:body"
      
      def save(options = {})
        return false if !valid?
        
        authorize
        
        page = agent.get("http://webdev5.com/submit")
        form = page.forms.detect {|form| form.form_node["id"] == "node-form"}
        
        form["url"] = url
        form["title"] = title
        form["body"] = body
        form.field_with(:name => "taxonomy[1]").options.each do |option|
          
        end
        form["taxonomy[tags][2]"] = token[:tags]
      end
    end
  end
end
