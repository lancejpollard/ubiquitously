module Ubiquitously
  module Twitter
    class Account < Ubiquitously::Service::Account
      uses :oauth
      
      def login
        # only login if we don't have cookies
        url = "http://localhost:4567/"
        hash = TwitterToken.authorize(url)
        options = {:url => hash[:url]}
        if cookies?
          options.merge!(:headers => {"Cookie" => user.cookies_for(:twitter)})
          page = agent.get(options, [], url)
        else
          page = agent.get(options, [], url)
          form = page.forms.first
          form["session[username_or_email]"] = username
          form["session[password]"] = password
          page = form.submit
        end
        
        authorize!(page.title =~ /Redirecting you back to the application/i)
        
        location = URI.parse(page.links.first.href)
        verifier = Rack::Utils.parse_query(location.query)["oauth_verifier"]
        
        # do something with the oauth token, save it in the cookie?
        self.credentials = TwitterToken.access(
          :token => hash[:token],
          :secret => hash[:secret],
          :oauth_verifier => verifier
        )
        
        logged_in?
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("")
      end
    end
  end
end
