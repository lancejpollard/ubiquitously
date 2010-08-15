module Ubiquitously
  module Propeller
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.propeller.com/signin/")
        form = page.forms.detect {|form| form.form_node["class"] == "ajax-form"}
        form["member_name"] = username
        form["password"]    = password
        form["submit"]      = "sign in" # require to get around the ajax
        page                = form.submit

        @logged_in = (page.body =~ /Invalid member name or password/i).nil? && (page.body =~ /ajax-form/).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Service::Post
      # title max == 150
      validates_presence_of :url, :title, :tags, :description
      
      def tokenize
        super.merge(:tags => tags.taggify("_", " "))
      end
      
      def create
        # url
        page        = agent.get("http://www.propeller.com/story/submit/")
        form        = page.forms.detect {|form| form.form_node["method"].downcase == "post"}
        form["url"] = token[:url]
        
        # details
        # http://www.propeller.com/story/submit/content/
        page        = form.submit
        form        = page.forms.detect {|form| form.form_node["method"].downcase == "post"}

        form.radiobuttons_with(:name => "title_multi").each do |button|
          button.check if button.value == "-1"
        end
        
        form["title_multi_text"] = token[:title]
        form["description"]      = token[:description]
        # separate by space, multi words are underscored
        form["user_tags"]        = token[:tags]
        
        form.radiobuttons_with(:name => "category").each do |button|
          button.check if button.value.to_s == "18"
        end
        
        # http://www.propeller.com/story/submit/preview/
        page = form.submit

        # approve
        page.forms[1].submit
        
        unless debug?
          page = form.submit
        end
        
        true
      end
    end
  end
end
