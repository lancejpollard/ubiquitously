module Ubiquitously
  module Reddit
    class User < Ubiquitously::Base::User
      def login
        return true if logged_in?
        
        page = agent.get("http://www.reddit.com/")
        form = page.form_with(:action => "http://www.reddit.com/post/login")
        form["user"]   = username
        form["passwd"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /login or register/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title
      
      def save
        return false unless valid?
        
        user.login
        
        page = agent.get("http://www.reddit.com/submit")
        form = page.form_with(:id => "newlink")
        form["title"] = title
        form["url"]   = url
        
        unless options[:debug] == true
          page = form.submit
        end
      end
    end
  end
end
