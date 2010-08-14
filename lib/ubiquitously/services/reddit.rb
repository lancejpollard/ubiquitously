module Ubiquitously
  module Reddit
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.reddit.com/")
        form = page.form_with(:action => "http://www.reddit.com/post/login")
        form["user"]   = username
        form["passwd"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /login or register/i).nil?
        
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
        authorize
        
        page = agent.get("http://www.reddit.com/submit?url=#{url}")
        key = page.body.match(/modhash\:\s+'([^']+)'/)[1]
        
        if page.parser.css(".infobar a").first.text =~ /submit it again/i
          post = page.parser.css(".thing").first
          id = post["class"].match(/id-(\w+)/)[1]
          vh = post.css(".arrow.up").first["onclick"].match(/\((?:\s+)?['"](\w+)['"]/)[1]
          post_site = page.body.match(/post_site:\s+['"]([^'"]+)['"]/)[1] rescue "javascript"
          params = {
            "id" => id,
            "vh" => vh,
            "dir" => 1,
            "uh" => key,
            "renderstyle" => "html",
            "r" => post_site
          }
          
          # dir = 1, 0, or -1. “direction” of vote.
          headers = {
            "X-Requested-With" => "XMLHttpRequest",
            "Accept" => "application/json, text/javascript, */*"
          }
          unless options[:debug] == true
            page = agent.post("http://www.reddit.com/api/vote", params, headers)
          end
        else
          form = page.forms.detect {|form| form.form_node["id"] == "newlink"}
          form["title"] = title
          form["url"]   = url
          form["id"] = "#newlink"
          form["uh"] = key
          form["renderstyle"] = "html"
          form["kind"] = "link"
          
          form.action = "http://www.reddit.com/api/submit"
          headers = {
            "X-Requested-With" => "XMLHttpRequest"
          }
          unless options[:debug] == true
            page = form.submit(nil, headers)
          end
        end
      end
    end
  end
end
