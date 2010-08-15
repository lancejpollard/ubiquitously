module Ubiquitously
  module Post
    module Restful
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods
        subclassable_callbacks :create, :update, :save, :destroy
      
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
      end
    
      module InstanceMethods
      
        def _save
          create_or_update
        end
      
        def create_or_update
          new_record? ? create : update
        end
      
        def save!
          save || raise Ubiquitously::RecordInvalid.new("Record is invalid: #{self.errors.full_messages}")
        end
      
        def remote
          @remote ||= self.class.find(:url => self.url, :user => self.user)
        end
      
        def new_record?
          remote.blank?
        end
      end
    end
  end
end
