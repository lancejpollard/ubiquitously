module Ubiquitously
  module Account
    module Authorizable
      def self.included(base)
        base.extend ClassMethods
        base.validates_presence_of :username, :password
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def uses(*protocols)
          @uses = protocols.flatten.map(&:to_s) unless protocols.blank?
          @uses ||= []
          @uses
        end
        
        def uses?(protocol)
          uses.include?(protocol.to_s)
        end
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
        
        def uses?(protocol)
          self.class.uses?(protocol)
        end
        
        def requires_credentials?
          uses?(:oauth)
        end
        
        def authorized?
          return true if logged_in?
          return (credentials? && cookies?) if requires_credentials?
          return cookies?
        end
        
      end
    end
  end
end
