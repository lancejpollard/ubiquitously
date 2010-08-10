module Ubiquitously
  module Posterous
    class Account < Ubiquitously::Base::Account
    end
    
    class Post < Ubiquitously::Base::Post
      include HTTParty
      base_uri 'http://posterous.com/api'
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
        token = tokenize
        
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
