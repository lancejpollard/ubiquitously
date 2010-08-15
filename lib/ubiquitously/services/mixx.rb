module Ubiquitously
  module Mixx
    class Account < Ubiquitously::Service::Account
      def login
        
        page = agent.get("https://www.mixx.com/")
        form = page.form_with(:action => "https://www.mixx.com/save_login")
        form["user[loginid]"] = username
        form["user[password]"] = password
        page = form.submit

        authorized?((page.body =~ /login was unsuccessful/i).nil?)
      end
    end
    
    class Post < Ubiquitously::Service::Post
      def create
        token = tokenize
        
        page = agent.get("http://www.mixx.com/submit")
        form = page.form_with(:action => "http://www.mixx.com/submit/step2")
        form["thingy[page_url]"] = token[:url]
        page = form.submit
        
        already_submitted = page.parser.css(".flash.notice").first.text rescue ""
        if (already_submitted =~ /already submitted/i)
          form = page.forms.detect { |form| form.form_node["class"] =~ /vote-for/ }
          form.submit
          
          form = page.forms.detect { |form| form.form_node["id"] == "thingy_comment_form" }
          form["comment[body]"] = token[:description]
          form.submit
        else
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
          form["thingy[title]"] = token[:title]
          form["thingy[description]"] = token[:description]
          form["thingy[new_tags]"] = token[:tags]
          form["recaptcha_challenge_field"] = captcha_response
          form["recaptcha_response_field"] = captcha_says
        
          form.submit
        end
        
        true
      end
      
      class << self
        def find(options = {})
          records = []
          user = options[:user]
          user_url = "http://www.mixx.com/feeds/users/#{user.username_for(self)}"
          xml = Nokogiri::XML(open(user_url).read)
          urls = url_permutations(options[:url])
          
          xml.css("item").each do |node|
            title = node.css("title").first.text
            url   = node.xpath("mixx:source", {"mixx" => "http://www.mixx.com/mixxrss/"}).first.text
            description = node.css("description").first.text
            service_url = node.css("link").first.text
            record = new(
              :title => title,
              :url => url,
              :description => description,
              :service_url => service_url,
              :user => user
            )
            return record if urls.include?(record.url)
            records << record
          end
          
          options[:url] ? nil : records
        end
      end
    end
  end
end
