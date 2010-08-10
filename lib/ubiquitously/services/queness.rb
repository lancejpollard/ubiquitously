module Ubiquitously
  module Queness
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.queness.com/")
        form = page.form_with(:action => "http://www.queness.com/login.php")
        form["login[username]"] = username
        form["login[password]"] = password
        form.checkboxes.first.check
        page = form.submit

        @logged_in = (page.parser.css(".error").text =~ /Incorrect/i).nil?
        
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
        
        page = agent.get("http://www.queness.com/post")
        form = page.forms.detect { |form| !form.form_node.css(".postform").first.nil? }
        
        form["form[title]"] = token[:title]
        form["form[description]"] = token[:description]
        form["form[url]"] = token[:url]
        # 1-4 tags
        form.checkboxes_with(:name => "tags[]").each do |box|
          case box.value.to_s
          when "1", "12", "11", "3"
            box.check
          end
        end
        
        page = form.submit
        
        true
      end
    end
  end
end
