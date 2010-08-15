module Ubiquitously
  module BloggerDen
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.bloggerden.com/login")
        form = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorized?(page.title =~ /Like Digg/i)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      # title max length == 120
      submit_to "http://digg.com/submit?phase=2&url=:url&title=:title&bodytext=:description&topic=26"
      
      def tokenize
        super.merge(:title => self.title[0..120])
      end
      
      def create
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
        unless debug?
          form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
          page = form.submit
        end
        # has captcha, not done with this
        true
      end
    end
  end
end
