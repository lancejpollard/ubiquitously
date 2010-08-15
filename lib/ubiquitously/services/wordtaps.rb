module Ubiquitously
  module Wordtaps
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://wordtaps.com/wp-login.php")
        form = page.form_with(:name => "loginform")
        form["log"] = username
        form["pwd"] = password
        form.checkboxes.first.check
        page = form.submit
        
        authorize!(page.parser.css("#login_error").first.nil?)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
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
