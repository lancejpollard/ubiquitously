module Ubiquitously
  module Flikode
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://flikode.com/login")
        form = page.form_with(:name => "login")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorize!(page.uri != "http://flikode.com/login")
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://flikode.com/snippet")
        form = page.form_with(:name => "snippet")
        
        form["title"] = token[:title]
        form["description"] = token[:description]
        form["tags"] = token[:tags]
        
        form.field_with(:name => "language").options.each do |option|
          option.select if option.text.to_s.strip.downcase =~ /#{format}/
        end
        
        form.radiobuttons_with(:name => "choose").last.check
        
        form["snippet"] = token[:body]
        
        page = form.submit
        
        true
      end
    end
  end
end
