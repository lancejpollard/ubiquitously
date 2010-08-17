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
        self.services = []
        self.services << args.shift while args.length > 0 && args.first !~ /^-/
        title = self.services.pop unless Ubiquitously.include?(self.services.last)
        self.attributes = parse_options(args)
        self.attributes[:title] = title if title
        
        self.attributes.each do |key, value|
          self.send("#{key.to_s}=", value) if self.respond_to?(key)
        end 
      end
      
      def parse_options(attributes)
        
      end
      
      def run
        
      end
    end
  end
end
