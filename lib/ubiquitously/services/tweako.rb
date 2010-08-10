module Ubiquitously
  module Tweako
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://www.tweako.com/?q=user/login")
        form = page.forms.detect { |form| form.form_node["id"] == "user_login" }
        form["edit[name]"] = username
        form["edit[pass]"] = password
        page = form.submit
        
        @logged_in = (page.title =~ /^user account/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :tags, :description
      # Either your first 400 characters will be used,
      # or you can determine where the teaser ends
      # by starting a new paragraph before the first 400 characters.
      # Make sure there is no text formatting or images in the teasers!
      #
      # A comma-separated list of terms describing this content.
      # Example: photoshop, free software.
      # Limit the amount of terms to a maximum of 6. Please choose relevent and descriptive terms.
      # Enter tags in ALL lower-case letters, and ensure spelling is correct.
      def tokenize
        super.merge(
          :description => self.description[0..400],
          :tags => self.tags[0..6].map { |tag| tag.downcase.gsub(/[^a-z0-9]/, " ").squeeze(" ") }.join(", ")
        )
      end
      
      def save(options = {})
        return false unless valid?
        
        authorize
        
        token = tokenize
        
        page = agent.get("http://www.tweako.com/node/add/storylink")
        form = page.forms.detect { |form| form.form_node["id"] == "node-form" }
        
        form["edit[title]"] = token[:title]
        form["edit[vote_storylink_url]"] = token[:url]
        form.field_with(:name => "edit[taxonomy][1]").options.each do |option|
          option.select if option.value.to_s == "11"
        end
        form["edit[taxonomy][tags][2]"] = token[:tags]
        form["edit[body]"] = token[:description]
        form["op"] = "Submit"
        
        unless options[:debug] == true
          page = form.submit
        end
        
        true
      end
    end
  end
end
