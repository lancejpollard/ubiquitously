module Ubiquitously
  class Base
    include ActiveModel::Validations
    extend ActiveModel::Callbacks
    include ActiveModel::Serialization
    include SubclassableCallbacks
    
    def apply(attributes)
      attributes.each do |key, value|
        self.send("#{key.to_s}=", value) if self.respond_to?(key)
      end
    end
    
    def debug?
      Ubiquitously.debug?
    end
  end
end