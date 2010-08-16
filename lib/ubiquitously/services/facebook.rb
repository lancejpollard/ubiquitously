module Ubiquitously
  module Facebook
    class Account < Ubiquitously::Service::Account
      def login
        url = "http://localhost:4567/"
        authorize_url = FacebookToken.authorize(url)
        page = agent.get(authorize_url, [], url)
        form = page.forms.detect { |form| form.form_node["id"] == "login_form" }
        form["email"] = username
        form["pass"] = password
        begin
          page = form.submit
        rescue Exception => e
          puts e.inspect
        end
        
        location = URI.parse(page.response.to_hash["location"].to_a.first)
        code = Rack::Utils.parse_query(location.query)["code"]
        
        # do something with the oauth token, save it in the cookie?
        self.data = FacebookToken.access(:secret => code, :callback_url => url)
                
        authorize!(page.uri !~ /http:\/\/login\.facebook\.com\/login\.php/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("")
      end
    end
  end
end
