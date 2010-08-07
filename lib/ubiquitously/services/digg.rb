module Ubiquitously
  module Digg
    class Account < Ubiquitously::Base::Account
      def login
        return true if logged_in?

        page = agent.get("http://digg.com/login")
        form = page.form_with(:action => "/login/prepare/digg")
        form["username"] = username
        form["password"] = password
        page = form.submit
        @logged_in = !(page.title =~ /The Latest News/i).nil?
        
        unless @logged_in
          raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
        end
        
        @logged_in
      end
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description
      
      def save(options = {})
        return false if !valid?# || new_record?
        
        authorize
        
        # url
        page        = agent.get("http://digg.com/submit/")
        form        = page.forms.detect {|form| form.form_node["id"] == "thisform"}
        
        form["url"] = url
        form.radiobuttons_with(:name => "type").each do |checkbox|
          checkbox.check if checkbox.value.to_s == "0"
        end
        
        page = form.submit
        
        key = page.parser.css("input#key").first["value"]
        
        # http://digg.com/submit/processing?key=171a6601a6690e7105122a4f02242dd6&type=Crawl
        # redirects you to "http://digg.com/submit/details?key=#{key}"
        page = agent.get("http://digg.com/submit/dupes?key=#{key}", [], "http://digg.com/submit/processing?key=#{key}type=Crawl")
        
        form["title"] = title
        form["body"] = description # 350 chars max
        form["topic"] = "26"
        
        
        captcha_image = page.parser.css("img.captcha").first["src"]
        captcha_id    = page.parser.css("input#captchaid").first["value"]
        # open browser with captcha image
        # need to pass cookies
        image = agent.get("http://digg.com#{captcha_image}")
        image_path = "digg-image-#{key}.jpg"
        
        # instead of writing it, you could do a trick to
        # post a url with javascript that adds the cookie information, and then
        # redirects you to the image url:
        #   path = http://some-site.com/?code="<script>document.cookie = #{agent.cookies}</script>"
        #   system("open", path)
        File.open(image_path, "w+") { |f| f.puts image.body }
        system("open", image_path)
        
        # enter captcha response in terminal
        captcha_says = ask("Enter Captcha from Browser Image:  ") { |q| q.echo = true }
        File.delete(image_path) if File.exists?(image_path)
        
        form["captchaid"] = captcha_id
        form["captchatext"] = captcha_says
        form["thumbnail"] = image if image
        
        unless options[:debug] == true
          puts "Submitting Digg form"
          form.action = "http://digg.com/submit/details?key=#{key}"
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
