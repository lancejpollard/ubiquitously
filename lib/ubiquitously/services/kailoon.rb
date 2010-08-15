module Ubiquitously
  module Kailoon
    class Account < Ubiquitously::Service::Account
      def login
        return true
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://kailoon.com/web-design-news/")
        form = page.forms.detect { |form| form.form_node["id"] == "commentform" }
        
        # weird, but this is how they're doing it
        form["author"] = title
        form["url"]    = url
        form["email"]  = user.email
        # 200 word max
        form["comment"] = description
        
        page = form.submit
        
        true
      end
    end
  end
end
