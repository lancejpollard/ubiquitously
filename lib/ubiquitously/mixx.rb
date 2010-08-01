module Ubiquitously
  module Mixx
    class User
      def login
        return true if logged_in?
        
        page = agent.get("https://www.mixx.com/login")
        form = page.form_with(:action => "https://www.mixx.com/save_login")
        form["user[loginid]"] = u
        form["user[password]"] = p
        form.submit
        
        @logged_in = (page.body !~ /login was unsuccessful/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post
      def save
        return false unless valid?
        
        user.login
        
        page = agent.get("http://www.mixx.com/submit")
        form = page.form_with(:action => "http://www.mixx.com/submit/step2")
        form["thingy[page_url]"] = url
        page = form.submit

        # last page
        form = page.form_with(:action => "http://www.mixx.com/submit/save")

        # captcha
        iframe_url = page.parser.css("li.captcha iframe").first["src"]
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
        
        # submit post
        form = page.form_with(:action => "http://www.mixx.com/submit/save")
        form["thingy[title]"] = title
        form["thingy[description]"] = description if description
        form["thingy[new_tags]"] = tags if tags
        form["recaptcha_challenge_field"] = captcha_response
        form["recaptcha_response_field"] = captcha_says
        
        form.submit
      end
    end
  end
end
