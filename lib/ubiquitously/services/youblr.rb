module Ubiquitously
  module Youblr
    class Account < Ubiquitously::Service::Account
    end
    
    class Post < Ubiquitously::Service::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
      end
    end
  end
end
