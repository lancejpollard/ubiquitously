module Ubiquitously
  module Command
    class Base
      class << self
        def run(args)
          new(args).run
        end
      end
      
      attr_accessor :services, :attributes
      
      def initialize(args)
        self.attributes = options(args)
        self.attributes.each do |key, value|
          self.send("#{key.to_s}=", value) if self.respond_to?(key)
        end 
      end
      
      def options(attributes)
        
      end
      
      def run
        
      end
    end
  end
end
