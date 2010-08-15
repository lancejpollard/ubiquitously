module Ubiquitously
  module Ownable
    module Post
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
      end
      
      module InstanceMethods
        def agent
          user.agent
        end
        
        def username
          user.username_for(self)
        end
        
        def password
          user.password_for(self)
        end
        
        def authorize
          user.login(service)
        end
      end
    end
  end
end
