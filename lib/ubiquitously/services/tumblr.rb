module Ubiquitously
  module Tumblr
    class Account < Ubiquitously::Base::Account
    end
    
    class Post < Ubiquitously::Base::Post
      include HTTParty
      base_uri 'http://www.tumblr.com/api'
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
        token = tokenize
        
        # type == regular, link, quote, photo, conversation, video, audio, answer
        response = self.class.post("/write", {
          :body => {
            :email => user.username_for(self),
            :password => user.password_for(self),
            :type => "link",
            :name => token[:title],
            :url => token[:url],
            :description => token[:description],
            :tags => token[:tags],
          }
        })
        
        true
      end
    end
  end
end
