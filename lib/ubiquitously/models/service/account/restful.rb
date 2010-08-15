module Ubiquitously
  module Account
    module Restful
      def self.included(base)
        base.extend ClassMethods
        base.restful
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        def restful
          subclassable_callbacks :login
        end
      end
      
      module InstanceMethods
        
      end
    end
  end
end
