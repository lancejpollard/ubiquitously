module Ubiquitously
  module Restful
    module Post
      def self.included(base)
        base.extend ClassMethods
        base.restful
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        def restful
          subclassable_callbacks :create, :update, :destroy
        end
        
        def create(attributes = {})
          record = new(attributes)
          record.save
          record
        end
        
        def create!(attributes = {})
          record = new(attributes)
          record.save!
          record
        end
        
        def find(options = {})
          nil
        end
      end
      
      module InstanceMethods
      
        def save
          create_or_update
        end
        
        def create_or_update
          new_record? ? create : update
        end
        
        def save!
          save || raise(Ubiquitously::RecordInvalid.new("Record is invalid: #{self.errors.full_messages}"))
        end
        
        def new_record?
          self.remote.blank?
        end
      end
    end
  end
end
