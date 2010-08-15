module Ubiquitously
  module Loggable
    module Post
      def self.included(base)
        base.extend ClassMethods
        base.loggable
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def logger
          Ubiquitously.logger
        end
        
        def loggable
          before_create do
            unless valid?
              logger.info "[invalid] #{errors.full_messages}"
              return false
            end
            authorize
            return false unless new_record?
            logger.info "[create:before] #{tokenize.inspect}"
          end
          
          after_create do
            logger.info "[create:after] #{tokenize.inspect}"
          end
          
          before_update do
            unless valid?
              logger.info "[invalid] #{errors.full_messages}"
              return false
            end
            authorize
            logger.info "[update:before] #{tokenize.inspect}"
          end
          
          after_update do
            logger.info "[update:after] #{tokenize.inspect}"
          end
        end
        
        def service
          to_s.split("::")[1].underscore.gsub(/\s+/, "_").downcase
        end
      end
      
      module InstanceMethods
        def service
          self.class.service
        end
        
        def logger
          self.class.logger
        end
        
        def inspect
          "#<#{self.class.inspect} @url=#{self.url.inspect} @title=#{self.title.inspect} @tags=#{self.tags.inspect} @categories=#{self.categories.inspect}>"
        end
      end
    end
  end
end
