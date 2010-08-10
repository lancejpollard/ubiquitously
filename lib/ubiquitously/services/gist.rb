module Ubiquitously
  module Gist
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("https://gist.github.com/login")
        form = page.form_with(:action => "/session")
        form["login"] = username
        form["password"] = password
        page = form.submit
        
        @logged_in = !(page.uri == "https://gist.github.com/session")
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :title, :description, :format, :extension
      
      def tokenize
        super.merge(
          # make sure we have the extension
          :title => self.title.gsub(/(?:\.#{self.extension})?$/, ".#{self.extension}")
        )
      end
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://gist.github.com/")
        form = page.form_with(:action => "/gists")
        
        form.field_with(:name => "file_ext[gistfile1]").options.each do |option|
          if format == extension || format == option.text.to_s.downcase.strip
            option.select
            break
          end
        end
        
        form["file_name[gistfile1]"] = token[:title]
        form["file_contents[gistfile1]"] = token[:description]
        
        if public?
          button = form.buttons.last
        else
          form["action_button"] = "private"
          button = form.buttons.first
        end
        
        page = form.submit(button)
        
        true
      end
    end
  end
end
