module Ubiquitously
  module Diigo
    class Account < Ubiquitously::Service::Account
      
      def login
        page = agent.get("https://secure.diigo.com/sign-in")
        form = page.form_with(:name => "loginForm")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorized? (page.title =~ /Sign in/i).nil?
      end
      
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description, :tags
      submit_to "http://www.diigo.com/post?b_mode=0&c_mode=0&url=:url&title=:title&comments=:description&tag=:tags"
      
      # tags are space separated. Use " " for tag with multiple words.
      def tokenize
        super.merge(:tags => tags.taggify(" ", " "))
      end
      
      def create
        token = tokenize
        
        page = agent.get("https://secure.diigo.com/item/new/bookmark")
        form = page.forms.detect { |form| form.form_node["id"] == "newBookmarkForm" }
        form["url"] = token[:url]
        form["title"] = token[:title]
        form["description"] = token[:description]
        # tags are space separated. Use " " for tag with multiple words.
        form["tags"] = token[:tags]
        
        unless debug?
          page = form.submit
        end
      end
      
      class << self
        def find(options = {})
          records = []
          user = options[:user]
          user_url = "http://secure.diigo.com/rss/user/#{user.username_for(self)}"
          xml = Nokogiri::XML(open(user_url).read)
          
          urls = url_permutations(options[:url])
          
          xml.css("item").each do |node|
            title = node.css("title").first.text
            url   = node.css("link").first.text
            description = node.css("description").first.text
            record = new(
              :title => title,
              :url => url,
              :description => description,
              :user => user
            )
            return record if urls.include?(record.url)
            records << record
          end
          
          options[:url] ? nil : records
        end
      end
    end
  end
end
