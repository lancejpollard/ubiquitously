module Ubiquitously
  module Account
    module Loggable
      def self.included(base)
        base.extend ClassMethods
        base.loggable
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        def loggable
          before_login do
            if authorized?
              @logged_in = true 
              return false
            end
            logger.info "[login:before] #{inspect}"
          end
          
          after_login do
            user.save
            logger.info "[login:after] #{inspect}"
          end
        end
        
        def service
          name.split("::")[1].underscore.gsub(/\s+/, "_")
        end
        
        def logger
          Ubiquitously.logger
        end
      end
      
      module InstanceMethods
        def logger
          self.class.logger
        end
        
        def service
          self.class.service
        end
        
        def inspect
          "#<#{self.class.inspect} @username=#{username.inspect} @password=#{password.gsub(/./, "*").inspect} @service=#{service.inspect}>"
        end
      end
    end
  end
end
