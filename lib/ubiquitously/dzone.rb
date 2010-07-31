module Ubiquitously
  module Dzone
    class User < Ubiquitously::Base::User
      def login
        return true if logged_in?
        
        page = agent.get("http://www.dzone.com/links/loginLightbox.html")
        form = page.form_with(:action => "/links/j_acegi_security_check")
        form["j_username"] = username
        form["j_password"] = password
        page = form.submit
        
        @logged_in = (page.body !~ /Invalid username or password/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
      
      def create
        
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :service_url
      
      class << self
        
        def first(url)
          find(url).first
        end
        
        def last(url)
          find(url).last
        end
        
        def find(url)
          query = CGI.escape(url.gsub(/http(s)?\:\/\//, ""))
          search = "http://www.dzone.com/links/search.html?query=#{query}"
          html = Nokogiri::HTML(open(search).read)
          records = []
          
          html.css(".linkblock").each do |node|
            link = node.css(".thumb a").first["href"]
            header = node.css(".details h3 a").first
            title = header.text
            service_url = header["href"]
            records << Ubiquitously::Dzone::Post.new(
              :url => link,
              :title => title,
              :service_url => service_url
            )
          end
          
          records
        end
        
        # http://www.dzone.com/links/feed/user/<user_id>/rss.xml
        # check to see if dzone already has the url
        def new_record?(url, throw_error = false)
          exists = !find(url).blank?
          raise DuplicateError.new("DZone already links to #{url}") if throw_error && exists
          exists
        end
      end
      
      def save(options = {})
        return false unless valid? && new_record?
        
        user.login
        
        # url
        page        = agent.get("http://www.dzone.com/links/add.html")
        form        = page.form_with(:action => "/links/add.html")
        
        accepted_tags = []
        
        form.checkboxes_with(:name => "tags").each do |tag|
          accepted_tags << tag.value.to_s
        end
        
        unaccepted_tags = tags.select { |tag| !accepted_tags.include?(tag) }
        
        if unaccepted_tags.length > 0
          raise ArgumentError.new("DZone doesn't accept these tags: #{unaccepted_tags.inspect}, they want these:\n#{accepted_tags.inspect}")
        end
        
        form["title"] = title
        form["url"] = url
        form["description"] = description
        
        form.checkboxes_with(:name => "tags").each do |checkbox|
          checkbox.check if tags.include?(checkbox.value)
        end
        
        unless options[:debug] == true
          page = form.submit
        end
        
        true
      end
      
      def new_record?
        self.class.new_record?(url)
      end
    end
  end
end
