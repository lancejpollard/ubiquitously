module Ubiquitously
  module Twitter
    class Account < Ubiquitously::Service::Account
      def login
        referer = "http://localhost:4567/"
        url = FacebookToken.authorize_url(referer)
        page = agent.get(url, [], referer)
        form = page.forms.detect { |form| form.form_node["id"] == "login_form" }
        form["email"] = username
        form["pass"] = password
        page = form.submit
        
        # do something with the oauth token, save it in the cookie?
        
        authorized?(page.uri !~ /http:\/\/login\.facebook\.com\/login\.php/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("")
      end
    end
  end
end
