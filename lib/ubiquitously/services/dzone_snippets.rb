module Ubiquitously
  module DzoneSnippets
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://snippets.dzone.com/account/login")
        form = page.form_with(:action => "/account/login")
        form["username"] = username
        form["password"] = password
        form["commit"] = "Log In"
        page = form.submit
        
        @logged_in = page.uri != "http://snippets.dzone.com/account/login"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      
      def tokenize
        super.merge(
          :description => "<code>#{self.description}</code>",
          :tags => tags.map do |tag|
            tag.downcase.strip.gsub(/[^a-z0-9]/, "-").squeeze("-")
          end.join(" ")
        )
      end
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://snippets.dzone.com/")
        form = page.form_with(:action => "/posts/create")

        form["post[title]"] = token[:title]
        form["post[content]"] = token[:description]
        form["post[tag_list]"] = token[:tags]
        
        form["post[private]"] = 1 if private?
        page = form.submit
        
        File.open("dzone_snip.html", "w+") {|f| f.puts page.body}
        
        true
      end
    end
  end
end
