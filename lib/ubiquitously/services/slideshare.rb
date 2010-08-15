module Ubiquitously
  module Slideshare
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.slideshare.net/login")
        form = page.form_with(:action => "/login")
        form["user_login"] = username
        form["user_password"] = password
        form.checkboxes.first.check # remember
        form["login"] = "Login"
        page = form.submit
        
        authorize!(page.uri != "http://www.slideshare.net/login")
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        page = agent.get(url)
        
        header = {
          "X-Requested-With" => "XMLHttpRequest",
          "Referer" => token[:url],
          "Accept" => "application/json, text/javascript, */*"
        }
        
        id = page.parser.css(".viralShareItem a.bloggerShare").first["href"].split("/").last
        authenticity_token = page.parser.css("input[name=authenticity_token]").first["value"]
        user_id = agent.get("http://www.slideshare.net/#{user.username_for(self)}").body.match(/\"id\":(\d+)/)[1]
        
        # favorite
        params = {
          "authenticity_token" => authenticity_token,
          "favorite[tag_text]" => token[:tags],
          "slideshow_id" => id,
          "source" => "slideviewer",
          "undefined" => "undefined",
          "user_id" => user_id
        }
        
        result = agent.post("http://www.slideshare.net/favorite/create", params, header)
        
        commented = false
        page.parser.css(".comment").each do |comment|
          if comment["class"].match(/author-(\d+)/)[1].to_s == user_id.to_s
            commented = true
            break
          end
        end
        
        unless commented
          # comment
          params = {
            "authenticity_token" => authenticity_token,
            "followup_email" => "undefined",
            "followup_subscribe" => "1",
            "slide_order" => "1",
            "undefined" => "undefined",
            "version" => 2,
            "slide_id" => id,
            "comment[text]" => token[:description]
          }
          result = agent.post("http://www.slideshare.net/comment/create", params, header)
        end
        
        true
      end
    end
  end
end
