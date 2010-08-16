module Ubiquitously
  module Account
    module Authorizable
      def self.included(base)
        base.extend ClassMethods
        base.validates_presence_of :username, :password
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
      end
      
      module InstanceMethods
        def authorize!(condition)
          authorize(condition)
          
          unless logged_in?
            raise AuthenticationError.new("Invalid username or password for #{service.titleize}")
          end
          
          logged_in?
        end
        
        def authorize(condition)
          @logged_in = !!condition
        end
        
        def logged_in?
          @logged_in == true
        end
        
      end
    end
  end
end
