module Ubiquitously
  module MvcForge
    class Account < Ubiquitously::Base::Account
      # raises Net::HTTPForbidden 403 if already logged in
      def login
        page = agent.get("http://mvcforge.com/user/login")
        form = page.forms.detect { |form| form.form_node["id"] == "user-login" }
        form["name"] = username
        form["pass"] = password
        
        page = form.submit
        
        match = page.parser.css(".messages.error").first.text =~ /unrecognized username or password/i).nil? rescue true
        
        authorized? match
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def create
        token = tokenize
        
        page = agent.get("http://mvcforge.com/submit")
        form = page.form_with(:action => "/submit")
        
        form["url"] = token[:url]
        form["title"] = token[:title]
        form["body"] = token[:description]
        form["taxonomy[tags][3]"]
        form.field_with(:name => "taxonomy[1]").options.each do |option|
          option.select if option.value.to_s == "90"
        end
        form["op"] = "Submit"
        
        page = form.submit(form.button_with(:value => "Submit"))
        
        true
      end
    end
  end
end
