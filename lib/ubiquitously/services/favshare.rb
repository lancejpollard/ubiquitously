module Ubiquitously
  module Favshare
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?
        
        page = agent.get("http://favshare.net/login.php")
        form = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        form["username"] = username
        form["password"] = password
        form["persistent"] = "persistent"
        form["processlogin"] = "1"
        page = form.submit
        
      end
    end
    
    # see your posts here: http://favshare.net/user/history/viatropos/
    class Post < Ubiquitously::Base::Post
      
      # max tags == 40 chars
      def tokenize
        max = 40
        super.merge(
          :tags => tags.chop(", ", 40).map do |tag|
              tag.downcase.gsub(/[^a-z0-9]/, " ").squeeze(" ")
            end.join(", ")
        )
      end
      
      def save(options = {})
        return false if !valid?
        
        authorize
        token = tokenize
        
        page = agent.get("http://favshare.net/submit.php")
        form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        
        form["url"] = url
        
        page        = form.submit
        form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        
        form["title"] = title
        form["bodytext"] = description # 350 chars max
        form["summarytext"] = description
        # MALFORMATTED HTML: select box is outside of the form
        #form.fields_with(:name => "category").first.options.each do |option|
        #  option.select if option.value.to_s == "3"
        #end
        # b/c of malformedness...
        form["category"] = "3"
        form["url"] = url
        form["phase"] = "2"
        form["randkey"] = page.parser.css("input[@name='randkey']").first["value"]
        form["id"] = page.parser.css("input[@name='id']").first["value"]
        
        form["tags"] = token[:tags] # comma separated with space
        
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
        File.open("favshare.html", "w+") {|f| f.puts page.parser.to_html}
        unless options[:debug] == true
          form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
          page = form.submit
        end
        
        true
      end
    end
  end
end
