module Ubiquitously
  module StumbleUpon
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.stumbleupon.com/login.php")
        form = page.form_with(:name => "formLogin")
        form["username"] = username
        form["password"] = password
        page = form.submit

        @logged_in = !(page.body =~ /Currently logged in/i).blank?

        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      def save(options = {})
        return false unless valid?
        
        authorize
        
        page = agent.get("http://www.stumbleupon.com/submit?url=#{url}&title=#{title}")
        form = page.forms.first
        form["topic"] = title
        form["comment"] = description
        form.radiobuttons_with(:name => "sfw").first.check
        page = agent.submit(form)
        
        # add tags
        page = agent.get("http://www.stumbleupon.com/favorites/")
        # get key properties
        token = page.parser.css("div#wrapperContent").first["class"]
        var = page.parser.css("li.listLi var").first
        comment_id = var["id"]
        public_id   = var["class"]
        
        # post to hidden api
        url    = "http://www.stumbleupon.com/ajax/edit/comment"
        params = {
          "syndicate_fb"  =>"syndicate_fb",
          "title"         => title,
          "token"         => token,
          "sticky_post"   => "0",
          "review"        => description,
          "tags"          => tags.join(", "),
          "publicid"      => public_id,
          "syndicate_tw"  => "syndicate_tw",
          "commentid"     => comment_id,
          "keep_date"     => "1"
        }
        
        page   = agent.post(url, params)
      end
    end
  end
end
