module Ubiquitously
  module Snipt
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://snipt.net/login")
        form = page.form_with(:name => "fauth")
        form["username"] = username
        form["password"] = password
        form["blogin"] = "Login"
        page = form.submit
        
        @logged_in = page.uri != "http://snipt.net/login"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://snipt.net/#{user.username_for(self)}")
        form = page.forms.detect { |form| form.form_node["id"] == "snippet-form" }
        form["description"] = token[:title]
        form["code"] = token[:description]
        form["tags"] = token[:tags]
        form.field_with(:name => "lexer").options.each do |option|
          option.select if (format == option.value || format == option.text.to_s.downcase)
        end
        form["public"] = public? ? "True" : "False"
        form["id"] = "0"
        
        # trailing slash matters
        form.action = "/save/"
        
        headers = {
          "X-Requested-With" => "XMLHttpRequest",
          "Accept" => "application/json, text/javascript, */*",
          "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
          "Pragma" => "no-cache",
          "Cache-Control" => "no-cache",
          "Accept-Encoding" => "gzip,deflate"
        }

        page = form.submit(nil, headers)
        
        url  = JSON.parse(page.body)["slug"] rescue nil
        
        true
      end
    end
  end
end
