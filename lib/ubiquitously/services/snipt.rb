module Ubiquitously
  module Snipt
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://snipt.net/login")
        form = page.form_with(:name => "fauth")
        form["username"] = username
        form["password"] = password
        form["blogin"] = "Login"
        page = form.submit
        
        authorize!(page.uri != "http://snipt.net/login")
      end
    end
    
    class Post < Ubiquitously::Service::Post      
      def create
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
