# digg now uses oauth, so switch when we have oauth through terminal
module Ubiquitously
  module Digg
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://digg.com/login")
        form = page.form_with(:action => "/login/prepare/digg")
        form["username"] = username
        form["password"] = password
        page = form.submit
        
        authorized? !(page.title =~ /The Latest News/i).nil?
      end
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description
      submit_to "http://digg.com/submit?phase=2&url=:url&title=:title&bodytext=:description&topic=26"
      
      def create
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
      
      def update
        token = nil
        page = agent.get(remote.service_url)
        page.parser.css("script").each do |script|
          if script["src"] =~ /http:\/\/digg\.com\/dynjs\/loader/
            token = agent.get(script["src"]).body.match(/tokens\.digg\.perform\s+=\s+"([^"]+)"/)[1]
          end
        end
        location = page.body.match(/D\.meta\.page\.type\s+=\s+"([^"]+)"/)[1]
        headers = {
          "X-Requested-With" => "XMLHttpRequest",
          "Accept" => "application/json, text/javascript",
          "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
          "Pragma" => "no-cache",
          "Cache-Control" => "no-cache",
          "Accept-Encoding" => "gzip,deflate",
          "Referer" => self.remote.service_url
        }
        params = {
          "location" => location,
          "token" => token,
          "itemid" => remote.service_id
        }#.inject([]) { |array, (k, v)| array << "#{k}=#{v}"; array }.join("&")
        string = params.inject([]) { |array, (k, v)| array << "#{k}=#{v}"; array }.join("&")
        begin
          page = agent.post("http://digg.com/ajax/digg/perform", params, headers)
        rescue Exception => e
          puts e.page.body
        end
        
        true
      end
      
      class << self
        def find(options = {})
          url = options[:url]
          raise ArgumentError.new("Please give #{service_name} a url") if url.blank?
          urls = url_permutations(options[:url])
          user = options[:user]
          records = []
          # search = "http://services.digg.com/1.0/endpoint?method=search.stories&query=#{url}"
          link = "http://services.digg.com/1.0/endpoint?method=story.getAll&link=#{url}"
          
          xml = Nokogiri::XML(user.agent.get(link).body)
          
          xml.css("story").each do |node|
            service_url = node["href"]
            service_id  = node["id"]
            url         = node["link"]
            votes       = node["diggs"].to_i
            title       = node.css("title").first.text
            description = node.css("description").first.text
            categories  = [node.css("container").first["name"]] rescue []
            categories  << node.css("topic").first["name"] rescue nil
            categories.flatten!
            record = new(
              :title => title,
              :url => url,
              :description => description,
              :categories => categories,
              :service_url => service_url,
              :service_id  => service_id,
              :votes => votes,
              :user => user
            )
            records << record if urls.include?(record.url)
          end
          
          records.sort! { |a, b| b.votes <=> a.votes }
          
          if options[:url]
            records.first
          else
            records
          end
        end
      end
    end
  end
end
