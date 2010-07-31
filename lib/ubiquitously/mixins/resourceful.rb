module Ubiquitously
  module Resourceful
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      def service_name
        self.to_s.split("::")[1].underscore.downcase
      end
      
      def required_arguments(*args)
        @required_arguments = args unless args.blank?
        @required_arguments ||= []
        @required_arguments
      end
      alias requires required_arguments
      
      def assert_required_arguments(options)
        missing = []
        required_arguments.each do |arg|
          missing << arg unless options.has_key?(arg)
        end
        unless missing.blank?
          raise ArgumentError.new("#{service_name.titleize} requires #{missing.join(", and")}") 
        end
        
        missing.blank?
      end
    end
    
    module InstanceMethods
      
      def initialize(attributes = {})
        attributes.each do |key, value|
          self.send("#{key.to_s}=", value) if self.respond_to?(key)
        end
      end
      
      def service_name
        self.class.service_name
      end
      
      def assert_required_arguments(options)
        self.class.assert_required_arguments(options)
      end
    end
  end
end
