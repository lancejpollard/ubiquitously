module Ubiquitously
  module Stumpedia
    class Account < Ubiquitously::Service::Account
    end
    
    class Post < Ubiquitously::Service::Post      
      def save(options = {})
        return false unless valid?
        
      end
    end
  end
end
