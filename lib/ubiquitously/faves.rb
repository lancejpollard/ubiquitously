module Ubiquitously
  module Faves
    class User < Ubiquitously::Base::User
      def login
        page = agent.get("https://secure.faves.com/signIn")
        form = page.forms.detect {|form| form.form_node["id"] == "signInBox"}
        form["rUsername"] = username
        form["rPassword"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /Sign In/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save
        return false unless valid?

        user.login
        
        page = agent.get("http://faves.com/createdot.aspx")
        form = page.form_with(:name => "createDotForm")
        form["noteText"] = description
        form["urlText"] = url
        form["subjectText"] = title
        form["tagsText"] = tags.join(", ")
        #form["rateSelect"]

        unless options[:debug] == true
          page = form.submit
        end
      end
    end
  end
end
