module Ubiquitously
  module Post
    module Loggable
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def logger
          Ubiquitously.logger
        end
      
        before_create do
          return false unless valid?
          authorize
          return false unless new_record?
          logger.info "[create:before] #{inspect}"
        end
      
        after_create do
          logger.info "[create:after] #{inspect}"
        end
      
        before_update do
          return false unless valid?
          authorize
          logger.info "[update:before] #{inspect}"
        end
      
        after_update do
          logger.info "[update:after] #{inspect}"
        end
      end
    
      module InstanceMethods
        def logger
          self.class.logger
        end
      
        def inspect
          "#<#{self.class.inspect} @url=#{self.url.inspect} @title=#{self.title.inspect} @description=#{self.description.inspect} @tags=#{self.tags.inspect}>"
        end
      end
    end
  end
end
