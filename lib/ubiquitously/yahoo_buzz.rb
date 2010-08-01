module Ubiquitously
  module YahooBuzz
    class User < Ubiquitously::Base::User
      def login
        page = agent.get("https://login.yahoo.com/config/login_verify2")
        form = page.form_with(:name => "login_form")
        form["login"] = username
        form["passwd"] = password
        page = form.submit
        
        # No match. Please try again        
        @logged_in = (page.title.to_s =~ /^Sign in/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end

        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url
      
      # yahoo has 4 ajax forms on one page, but they make it look like it's 2 steps
      def save(options = {})
        return false unless valid?
        
        user.login
        
        page = agent.get("http://buzz.yahoo.com/submit")
        
        headers = {
          "X-Requested-With" => "XMLHttpRequest",
          "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8"
        }
        
        # url form
        form = page.form_with(:name => "urlsubmissionform")
        if page.body =~ /YAHOO\.Buzz\.Submit\.QueryDataUrl \= \"\\\/submit\\\/get\;_ylt=([^\"]+)\"/i
          form.action = "http://buzz.yahoo.com/submit/get;_ylt=#{$1}"
        end

        form["url"] = url
        result = form.submit(nil, headers)
        
        # description form
        if description == "true?"
          form = page.forms.detect do |form|
            form.form_node["class"] == "inline-edit-form" &&
              !form.form_node.css("input[value=submitSummary]").first.blank?
          end
          form["fieldvalue"] = description
          form.submit(nil, headers)
        end
        
        # category form
        form = page.forms.detect do |form|
          form.form_node["class"] == "inline-edit-form" &&
            !form.form_node.css("input[value=submitCategory]").first.blank?
        end
        # form.field_with(:name => "fieldvalue")
        
        # captcha
        form = page.form_with(:name => "submissiondataform")
        captcha_image = form.form_node.css(".captcha-image img").first["src"]
        
        system("open", captcha_image)
        # enter captcha response in terminal
        captcha_says = ask("Enter Captcha from Browser Image:  ") { |q| q.echo = true }
        form["submitCaptcha"] = captcha_says
        result = form.submit(nil, headers)
      end
    end
  end
end
