module Ubiquitously
  module MetaFilter
    class Account < Ubiquitously::Service::Account
      def login
        return true if logged_in?
        
        page = agent.get("https://login.metafilter.com/")
        form = page.forms.first
        form["user_name"] = username
        form["user_pass"] = password
        page = form.submit
        
        # Login Error!
        @logged_in = page.uri == "https://login.metafilter.com/logging-in.mefi"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    # You cannot post to the front page at this time.
    # This can be due to one of several things.
    # You may not have been a member long enough (1 week),
    # you may not have posted enough comments (at least 3),
    # or you may have already posted a link in the past 24 hours.
    class Post < Ubiquitously::Service::Post
      def save(options = {})
        return false if !valid?
        
        authorize
        
        page = agent.get("http://www.metafilter.com/")
      end
    end
  end
end
