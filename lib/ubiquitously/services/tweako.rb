module Ubiquitously
  module Tweako
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.tweako.com/?q=user/login")
        form = page.forms.detect { |form| form.form_node["id"] == "user_login" }
        form["edit[name]"] = username
        form["edit[pass]"] = password
        page = form.submit
        
        authorize!(page.title !~ /^user account/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
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
          :tags => self.tags[0..6].taggify(" ", ", ")
        )
      end
      
      def create
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
        
        unless debug?
          page = form.submit
        end
        
        true
      end
    end
  end
end
