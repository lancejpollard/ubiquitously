module Ubiquitously
  module Queness
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.queness.com/")
        form = page.form_with(:action => "http://www.queness.com/login.php")
        form["login[username]"] = username
        form["login[password]"] = password
        form.checkboxes.first.check
        page = form.submit

        authorized?(page.parser.css(".error").text !~ /Incorrect/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
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
