module Ubiquitously
  module Webdev5
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://webdev5.com/user/login")
        form = page.forms.detect {|form| form.form_node["id"] == "user-login"}
        form["name"] = username
        form["pass"] = password
        page = form.submit
        
        authorize!(page.title.strip !~ /^User account/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      submit_to "http://webdev5.com/submit?url=:url&title=:title&body=:body"
      
      def create
        page = agent.get("http://webdev5.com/submit")
        form = page.forms.detect {|form| form.form_node["id"] == "node-form"}
        
        form["url"] = token[:url]
        form["title"] = token[:title]
        form["body"] = token[:body]
        form.field_with(:name => "taxonomy[1]").options.each do |option|
          
        end
        form["taxonomy[tags][2]"] = token[:tags]
      end
    end
  end
end
