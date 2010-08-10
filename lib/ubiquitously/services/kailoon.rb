module Ubiquitously
  module Kailoon
    class Account < Ubiquitously::Base::Account
      def login
        return true
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def save(options = {})
        return false if !valid?
        
        authorize
        
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
