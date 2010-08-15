module Ubiquitously
  module Account
    module Restful
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        subclassable_callbacks :login
      end
    
      module InstanceMethods
      
      end
    end
  end
end
