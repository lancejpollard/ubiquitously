module Ubiquitously
  module Newsvine
    class User < Ubiquitously::Base::User
      def login
        return true if logged_in?
        
        page = agent.get("https://www.newsvine.com/_nv/accounts/login")
        form = page.form_with(:action => "https://www.newsvine.com/_nv/api/accounts/login")
        form["email"] = username
        form["password"] = password
        page = form.submit
        
        # No match. Please try again        
        @logged_in = (page.title =~ /Log in/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title
      
      def save(options = {})
        return false unless valid?
        
        user.login
        
        page = agent.get("http://www.newsvine.com/_tools/seed")
        form = page.form_with(:action => "http://www.newsvine.com/_action/tools/saveLink")
        
        form["url"] = url
        form["headline"] = title
        form.radiobuttons_with(:name => "newsType").each do |button|
          button.check if button.value == "x"
        end
        form.field_with(:name => "categoryTag").options.each do |option|
          option.select if option.value == "technology"
        end
        form["blurb"] = description
        form["tags"] = tags.join(", ")
        
        unless options[:debug] == true
          page = form.submit
        end
        
        true
      end
    end
  end
end
