module Ubiquitously
  module Faves
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        puts 'logging in'
        page = agent.get("https://secure.faves.com/signIn")
        form = page.forms.detect {|form| form.form_node["id"] == "signInBox"}
        form["rUsername"] = username
        form["rPassword"] = password
        form["action"] = "Sign In"
        page = form.submit
        
        @logged_in = (page.title =~ /Sign In/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        puts 'logged in'
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        puts 'saving faves'
        return false unless valid?
        authorize
        
        page = agent.get("http://faves.com/createdot.aspx")
        form = page.form_with(:name => "createDotForm")
        form["noteText"] = description
        form["urlText"] = url
        form["subjectText"] = title
        form["tagsText"] = tags.join(", ")
        form.field_with(:name => "rateSelect").options.each do |option|
          option.select if option.value.to_s == "5"
        end
        form.field_with(:name => "shareSelect").options.each do |option|
          option.select if option.value.to_s.downcase == "public"
        end
        # hidden fields they fill out with javascript
#        form["imageUrl"] = "http://s3.amazonaws.com/github/ribbons/forkme_right_white_ffffff.png"
#        form["imageWidth"] = "149"
#        form["imageHeight"] = "149"
        # just before you submit the form they append the current time, so they have a range.
        # mimic the range of time :)
        form["authoringExpiry"] = form["authoringExpiry"] + "loadedtime=#{1.minute.ago.to_i * 1000}publishedtime=#{Time.now.to_i * 1000}"
        headers = {
          "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Keep-Alive" => "115",
          "Accept-Encoding" => "gzip,deflate"
        }
        
        unless options[:debug] == true
          puts "Submitting form to Faves"
          page = form.submit(nil, headers)
        end
        
        self
      end
      
      class << self
        def find(options = {})
          result = []
          user = options[:user]
          user_url = "http://faves.com/users/#{user.username_for(self)}"
          html = Nokogiri::HTML(open(user_url).read)
          
          html.css(".userDotList li").each do |node|
            next if node["id"].blank?
            url = node.css(".note > a").first["href"]
            title = node.css(".note > p").first.text
            tags = []
            node.xpath("a").each do |tag|
              tags << tag.text if tag["class"].blank?
            end
            record = new(
              :title => title,
              :url => url,
              :tags => tags
            )
            if options[:url] && options[:url] == record.url
              return record
            end
            result << record
          end
          
          options[:url] ? nil : result
        end
      end
    end
  end
end
