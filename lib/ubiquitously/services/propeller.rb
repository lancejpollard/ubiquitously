module Ubiquitously
  module Propeller
    class Account < Ubiquitously::Base::Account
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
    
    class Post < Ubiquitously::Base::Post
      # title max == 150
      validates_presence_of :url, :title, :tags, :description
      
      def save
        return false unless valid?
        
        user.login

        # url
        page        = agent.get("http://www.propeller.com/story/submit/")
        form        = page.forms.detect {|form| form.form_node["method"].downcase == "post"}
        form["url"] = url
        
        puts form.inspect
        # details
        # http://www.propeller.com/story/submit/content/
        page        = form.submit
        form        = page.forms.detect {|form| form.form_node["method"].downcase == "post"}
        puts "DETAILS"
        form.radiobuttons_with(:name => "title_multi").each do |button|
          button.check if button.value == "-1"
        end
        
        form["title_multi_text"] = title
        form["description"]      = description
        # separate by space, multi words are underscored
        form["user_tags"]        = tags.map {|tag| tag.underscore.gsub(/[\s|-]+/, "_")}.join(" ")
        
        form.radiobuttons_with(:name => "category").each do |button|
          button.check if button.value.to_s == "18"
        end
        
        # http://www.propeller.com/story/submit/preview/
        page = form.submit

        # approve
        page.forms[1].submit
        
        unless options[:debug] == true
          page = form.submit
        end
        
        true
      end
    end
  end
end
