module Ubiquitously
  module Account
    module Authorizable
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        validates_presence_of :username, :password
      end
    
      module InstanceMethods
        def authorized?(condition)
          @logged_in = !!condition
          
          unless @logged_in
            raise AuthenticationError.new("Invalid username or password for #{service_name.titleize}")
          end
        
          @logged_in
        end
      
        def logged_in?
          @logged_in == true
        end
      end
    end
  end
end
