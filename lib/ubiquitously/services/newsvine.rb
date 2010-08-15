module Ubiquitously
  module Newsvine
    class Account < Ubiquitously::Base::Account
      def login
        page = agent.get("https://www.newsvine.com/_nv/accounts/login")
        form = page.form_with(:action => "https://www.newsvine.com/_nv/api/accounts/login")
        form["email"] = username
        form["password"] = password
        page = form.submit
        
        # No match. Please try again
        match = (page.title =~ /Log in/i).nil?
        authorized? match
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title
      
      def tokenize
        super.merge(:tags => tags.taggify(" ", ", "))
      end
      
      def create
        page = agent.get("http://www.newsvine.com/_tools/seed")
        form = page.form_with(:action => "http://www.newsvine.com/_action/tools/saveLink")
        
        form["url"] = token[:url]
        form["headline"] = token[:title]
        form.radiobuttons_with(:name => "newsType").each do |button|
          button.check if button.value == "x"
        end
        form.field_with(:name => "categoryTag").options.each do |option|
          option.select if option.value == "technology"
        end
        form["blurb"] = token[:description]
        form["tags"] = token[:tags]
        
        unless debug?
          page = form.submit
        end
        
        true
      end
      
      class << self
        def find(options = {})
          records = []
          user = options[:user]
          user_url = "http://#{user.username_for(self)}.newsvine.com"
          html = Nokogiri::HTML(open(user_url).read)
          urls = url_permutations(options[:url])
          
          html.css(".quickpost").each do |node|
            title = node.css("h1").first.text rescue nil
            url   = node.css("a.external").first["href"] rescue nil
            description = node.xpath("p").first.text rescue nil
            service_url = node.css("h1 a").first["href"] rescue nil
            tags = []
            node.css(".tags a").each do |tag|
              tags << tag.text
            end
            record = new(
              :title => title,
              :url => url,
              :description => description,
              :tags => tags,
              :service_url => service_url,
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
