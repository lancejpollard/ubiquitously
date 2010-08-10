module Ubiquitously
  module Wordtaps
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://wordtaps.com/wp-login.php")
        form = page.form_with(:name => "loginform")
        form["log"] = username
        form["pwd"] = password
        form.checkboxes.first.check
        page = form.submit
        
        @logged_in = page.parser.css("#login_error").first.nil?
        
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
        
        page = agent.get("http://wordtaps.com/")
        form = page.form_with(:name => "new_post")
        
        form["posttitle"] = token[:title]
        form["posturl"] = token[:url]
        form.field_with(:name => "category").options.each do |option|
          option.select if option.value.to_s == "5"
        end
        # max length == 800
        form["tags"] = token[:tags]
        form["posttext"] = token[:description]
        
        page = form.submit
        
        true
      end
    end
  end
end
