module Ubiquitously
  module DzoneSnippets
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://snippets.dzone.com/account/login")
        form = page.form_with(:action => "/account/login")
        form["username"] = username
        form["password"] = password
        form["commit"] = "Log In"
        page = form.submit
        
        authorize!(page.uri != "http://snippets.dzone.com/account/login")
      end
    end
    
    class Post < Ubiquitously::Service::Post
      
      def tokenize
        super.merge(
          :description => "<code>#{self.description}</code>",
          :tags => tags.taggify("-", " ", 40)
        )
      end
      
      def create
        page = agent.get("http://snippets.dzone.com/")
        form = page.form_with(:action => "/posts/create")
        
        form["post[title]"] = token[:title]
        form["post[content]"] = token[:description]
        form["post[tag_list]"] = token[:tags]
        form["post[private]"] = 1 if private?
        page = form.submit
        
        true
      end
    end
  end
end
