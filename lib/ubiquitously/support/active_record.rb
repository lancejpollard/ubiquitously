module Ubiquitously
  module Support
    module ActiveRecord
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        attr_accessor :ubiquitously_accounts
        
        def ubiquitous(*args)
          self.ubiquitously_accounts = args.flatten.map(&:to_s).uniq.map do |service|
            "Ubiquitously::#{service.camelize}::Account".constantize
          end
        end
      end
      
      module InstanceMethods
        def ubiquitously
          @ubiquitously ||= Ubiquitously::User.new
        end
      end
    end
  end
end
