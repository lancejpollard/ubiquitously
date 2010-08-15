module Ubiquitously
  module Dzone
    class Account < Ubiquitously::Service::Account
      def login
        page = agent.get("http://www.dzone.com/links/loginLightbox.html")
        form = page.form_with(:action => "/links/j_acegi_security_check")
        form["j_username"] = username
        form["j_password"] = password
        form["_acegi_security_remember_me"] = "on"
        page = form.submit
        
        authorized? (page.body =~ /Invalid username or password/i).nil?
      end
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description, :categories
      submit_to "http://www.dzone.com/links/add.html?url=:url&title=:url&description=:description"      
      
      def create
        token = tokenize
        # url
        page        = agent.get("http://www.dzone.com/links/add.html")
        form        = page.form_with(:action => "/links/add.html")
        
        accepted_tags = []
        
        form.checkboxes_with(:name => "tags").each do |tag|
          accepted_tags << tag.value.to_s
        end
        
        unaccepted_tags = token[:categories].select { |tag| !accepted_tags.include?(tag) }
        
        if unaccepted_tags.length > 0
          raise ArgumentError.new("DZone doesn't accept these tags: #{unaccepted_tags.inspect}, they want these:\n#{accepted_tags.inspect}")
        end
        
        form["title"] = title
        form["url"] = url
        form["description"] = description
        
        form.checkboxes_with(:name => "tags").each do |checkbox|
          checkbox.check if token[:categories].include?(checkbox.value)
        end
        
        unless debug?
          page = form.submit
        end
        
        true
      end
      
      def update
        page = agent.get(remote.service_url)
        params = "\ncallCount=1\n"
        params << "c0-scriptName=LinkManager\n"
        params << "c0-methodName=incrementVoteCount\n"
        # var random = Math.floor(Math.random() * 10001);
        # var id = (random + "_" + new Date().getTime()).toString();
        # => 9031_1281646074042
        # => 5155_1281650444000
        js_time = (Time.now.utc - Time.utc(1970, 1, 1)).floor * 1000
        params << "c0-id=#{rand(10001).to_s}_#{js_time.to_s}\n"
        params << "c0-param0=number:#{remote.service_id}\n"
        params << "c0-param1=number:1\n"
        params << "c0-param2=boolean:false\n"
        params << "xml=true\n"
        headers = {
          "Content-Type" => "text/plain; charset=UTF-8",
          "Referer" => remote.service_url,
          "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Encoding" => "gzip,deflate",
          "X-Requested-With" => "XMLHttpRequest",
          "Pragma" => "no-cache",
          "Cache-Control" => "no-cache"
        }
        result = agent.post("http://www.dzone.com/links/dwr/exec/LinkManager.incrementVoteCount.dwr", params, headers)
        
        # now add comment
        form = page.form_with(:name => "addlinkform")
        form["body"] = description
        
        form.submit
        
        true
      end
      
      class << self
        
        def find(options = {})
          url = options[:url]
          user = options[:user]
          urls = url_permutations(url)
          records = []
          
          for page in 1..10
            search = "http://dzone.com/links/search.html?query=#{URI.parse(url).host}&type=html&p=#{page}"
            html = user.agent.get(search).parser
            
            html.css(".linkblock").each do |node|
              service_id = node["id"].match(/(\d+)/)[1]
              link = node.css(".thumb a").first["href"]
              header = node.css(".details h3 a").first
              title = header.text
              upvotes = node.css(".vwidget .upcount").first.text.to_i
              downvotes = node.css(".vwidget .downcount").first.text.to_i
              service_url = "http://www.dzone.com#{header["href"]}"
              record = new(
                :url => link,
                :title => title,
                :upvotes => upvotes,
                :downvotes => downvotes,
                :service_url => service_url,
                :service_id => service_id,
                :user => user
              )
              if urls.include?(record.url)
                records << record
                break
              end
            end
            
            break if records.length > 0
          end
          
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
