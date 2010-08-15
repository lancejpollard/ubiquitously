module Ubiquitously
  module Account
    module Loggable
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        before_login do 
          return false if logged_in?
          logger.info "[login:before] #{inspect}"
        end
      
        after_login do
          logger.info "[login:after] #{inspect}"
        end
      end
      
      module InstanceMethods
        def inspect
          "#<#{self.class.inspect} @username=#{username.inspect} @password=#{password.gsub(/./, "*").inspect} @service=#{service_name.inspect}>"
        end
      end
    end
  end
end
