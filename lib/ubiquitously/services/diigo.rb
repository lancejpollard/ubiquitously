module Ubiquitously
  module Diigo
    class Account < Ubiquitously::Base::Account
      
      def login
        return true if logged_in?
        
        page = agent.get("https://secure.diigo.com/sign-in?referInfo=http://www.diigo.com")
        form = page.form_with(:name => "loginForm")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /Sign in/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
      
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false if !valid? || new_record?

        authorize
        
        page = agent.get("https://secure.diigo.com/item/new/bookmark")
        form = page.form_with(:action => "/item/save/bookmark")
        form["url"] = url
        form["title"] = title
        form["description"] = description
        # tags are space separated. Use " " for tag with multiple words.
        form["tags"] = tags.map do |tag|
          '"' + tag.downcase.strip.gsub(/[^a-z0-9]/, " ").squeeze(" ") + '"'
        end.join(" ")
        
        unless options[:debug] == true
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
