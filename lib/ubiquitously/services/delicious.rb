module Ubiquitously
  module Delicious
    class Account < Ubiquitously::Service::Account
      def login
        true
      end
    end
    
    class Post < Ubiquitously::Service::Post
      include HTTParty
      base_uri 'https://api.del.icio.us/v1'
      submit_to "http://del.icio.us/post/?url=:url&title=:title&notes=:description&tags=:tags"
      
      def tokenize
        super.merge(:tags => tags.taggify("-", " "))
      end
      
      def create
        puts "CREATE #{@auth.inspect}"
        res = self.class.get(
          "/posts/add",
          :query => {
            :url => url,
            :description => title,
            :extended => description,
            :tags => tags.map { |tag| tag.downcase.gsub(/[^a-z0-9]/, "-").squeeze("-") }.join(" ")
          },
          :basic_auth => @auth
        )
        puts "RESPONSE: #{res.inspect}"
        true
      end
      
      def remote(options = {})
        return nil
        raise "what url to do want" if self.url.nil?
        @remote ||= self.class.find(options.merge(
          :query => {
            :url => CGI.escape(self.url)
          },
          :basic_auth => @auth
        ))
      end
      
      class << self
        def find(options = {})
          options[:result] = options.delete(:count) unless options[:count].nil?
          raise "enter ':basic_auth => {:username => x, :password => y}'" unless options[:basic_auth]
          self.get('/posts/get', options)
        end
      end
    end
  end
end
