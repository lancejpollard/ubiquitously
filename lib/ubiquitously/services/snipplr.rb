# snipplr stores an encrypted version of your password in the cookies, watch out!
# only uses last tag in array :/
module Ubiquitously
  module Snipplr
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://snipplr.com/login/")
        form = page.form_with(:action => "/login/")
        form["username"] = username
        form["password"] = password
        form["btnsubmit"] = "LOGIN"
        page = form.submit
        
        @logged_in = page.uri != "http://snipplr.com/login/"
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      
      def tokenize
        super.merge(
          :tags => tags.map do |tag|
            tag.downcase.strip.gsub(/[^a-z0-9]/, " ").squeeze(" ")
          end.map do |tag|
            (tag =~ /\s+/).nil? ? tag : "\"#{tag}\"" 
          end.join(" ")
        )
      end
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://snipplr.com/new/")
        form = page.form_with(:action => "/new/")
        
        form["title"] = token[:title]
        form["url"] = token[:title].downcase.strip.gsub(/[^a-z0-9]/, "-").squeeze("-")
        form["source"] = token[:description]
        form["tags"] = token[:tags]
        form.field_with(:name => "lang").options.each do |option|
          if option.text.to_s.downcase.strip == format
            option.select
            break
          end
        end
        form["private"] = 1 if private?
        
        
        # captcha
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
        form["recaptcha_response_field"] = captcha_says
        form["btnsubmit"] = "POST"
        
        page = form.submit
        
        true
      end
    end
  end
end
