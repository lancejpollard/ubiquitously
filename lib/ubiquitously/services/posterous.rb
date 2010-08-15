module Ubiquitously
  module Posterous
    class Account < Ubiquitously::Service::Account
    end
    
    class Post < Ubiquitously::Service::Post
      include HTTParty
      base_uri 'http://posterous.com/api'
      validates_presence_of :url, :title, :description, :tags
      
      def create
        self.class.post("/newpost", {
          :query => {
            :title => token[:title],
            :body => token[:description],
            :tags => token[:tags]
          },
          :basic_auth => @auth
        })
        
        true
      end
    end
  end
end
