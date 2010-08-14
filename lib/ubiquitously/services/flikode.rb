module Ubiquitously
  module Flikode
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://flikode.com/login")
        form = page.form_with(:name => "login")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = page.uri != "http://flikode.com/login"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def save(options = {})
        return false unless valid?
        
        authorize
        token = tokenize
        
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
