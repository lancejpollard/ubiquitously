module Ubiquitously
  module Identica
    class Account < Ubiquitously::Base::Account
    end
    
    class Post < Ubiquitously::Base::Post
      validates_presence_of :url, :title, :description, :tags
      
      def save(options = {})
        return false unless valid?
        
      end
    end
  end
end
