module Ubiquitously
  module MetaFilter
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("https://login.metafilter.com/")
        form = page.forms.first
        form["user_name"] = username
        form["user_pass"] = password
        page = form.submit
        
        authorize!(page.uri != "https://login.metafilter.com/logging-in.mefi")
      end
    end
    
    # You cannot post to the front page at this time.
    # This can be due to one of several things.
    # You may not have been a member long enough (1 week),
    # you may not have posted enough comments (at least 3),
    # or you may have already posted a link in the past 24 hours.
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get("http://www.metafilter.com/")
      end
    end
  end
end
