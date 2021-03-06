module Ubiquitously
  module StumbleUpon
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.stumbleupon.com/login.php")
        form = page.form_with(:name => "formLogin")
        form["username"] = username
        form["password"] = password
        page = form.submit

        authorize!(page.body =~ /Currently logged in/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      submit_to "http://www.stumbleupon.com/submit?url=:url&title=:title"
      
      def create
        page = agent.get("http://www.stumbleupon.com/favorites/")
        action    = "http://www.stumbleupon.com/ajax/edit/comment"

        form = page.forms.detect do |form|
          !form.form_node.css("textarea#review").first.blank?
        end
        
        headers = {
          "X-Requested-With" => "XMLHttpRequest",
          "Accept" => "application/json, text/javascript, */*"
        }
        
        # get key properties
        key = page.parser.css("div#wrapperContent").first["class"]
        var = page.parser.css("li.listLi var").first
        comment_id = var["id"].blank? ? 0 : var["id"]
        public_id   = var["class"].blank? ? "" : var["class"]
        
        # post to hidden api
        params = {
          "url"           => token[:url],
          "title"         => token[:title],
          "review"        => token[:description],
          "tags"          => token[:tags],
          "token"         => key,
          "sticky_post"   => "0",
          "publicid"      => "",
          "syndicate_fb"  =>"syndicate_fb",
          "syndicate_tw"  => "syndicate_tw",
          "commentid"     => 0,
          "new_post"      => 1,
          "blog_post"     => 0,
          "keep_date"     => 0
        }
        
        form.action = action
        form.method = "POST"
        
        params.each do |k, v|
          form[k] = v
        end
        
        page   = form.submit(nil, headers)
        
        true
      end
    end
  end
end
