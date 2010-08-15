module Ubiquitously
  module BloggerDen
    class Account < Ubiquitously::Service::Account
      def login
        return true if logged_in?

        page = agent.get("http://www.bloggerden.com/login")
        form = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        form["username"] = username
        form["password"] = password
        page = form.submit
        @logged_in = !(page.title =~ /Like Digg/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description
      # title max length == 120
      submit_to "http://digg.com/submit?phase=2&url=:url&title=:title&bodytext=:description&topic=26"
      
      def tokenize
        super.merge(
          :title => self.title[0..120],
          :tags => self.tags.map { |tag| tag.downcase.gsub(/[^a-z0-9]/, " ").squeeze(" ") }.join(", ")
        )
      end
      
      def save(options = {})
        return false if !valid?# || new_record?
        
        authorize
        
        # url
        page        = agent.get("http://www.bloggerden.com/submit/")
        form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        
        form["url"] = url
        
        page        = form.submit
        form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        
        form["title"] = title
        form["bodytext"] = description # 350 chars max
        form.radiobuttons_with(:name => "category").each do |button|
          button.check if button.value.to_s == "38"
        end
        
        iframe_url = page.parser.css("noscript iframe").first["src"]
        params     = iframe_url.split("?").last
        captcha_iframe = agent.click(page.iframes.first)
        captcha_form = captcha_iframe.forms.first
        captcha_image = captcha_iframe.parser.css("img").first["src"]
        # open browser with captcha image
        system("open", "http://api.recaptcha.net/#{captcha_image}")
        # enter captcha response in terminal
        captcha_says = ask("Enter Captcha from Browser Image:  ") { |q| q.echo = true }
        captcha_form["recaptcha_response_field"] = captcha_says
        # submit captcha
        captcha_form.action = "http://www.google.com/recaptcha/api/noscript?#{params}"
        captcha_response = captcha_form.submit
        # grab secret
        captcha_response = captcha_response.parser.css("textarea").first.text
        
        form["recaptcha_challenge_field"] = captcha_response
        form["recaptcha_response_field"] = "manual_challenge"
        
        page = form.submit
        unless options[:debug] == true
          form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
          page = form.submit
        end
        # has captcha, not done with this
        true
      end
      
      def new_record?
        self.class.new_record?(url)
      end
    end
  end
end
