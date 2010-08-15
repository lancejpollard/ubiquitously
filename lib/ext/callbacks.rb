require 'rubygems'
require 'active_model'

# use this if you want to create before and after filters around a commonly used
# method, but still want to define the method in subclasses.
module SubclassableCallbacks
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    attr_accessor :subclassable_callbacks
    
    def subclassable_callbacks(*methods)
      @subclassable_callbacks ||= []
      
      unless methods.empty?
        @subclassable_callbacks = @subclassable_callbacks.concat(methods).flatten.compact.map(&:to_sym).uniq
        define_model_callbacks *methods
        class_eval do
          methods.each do |variable|
            define_method "_#{variable.to_s}" do; end
            define_method variable do
              send("_run_#{variable.to_s}_callbacks") do
                send("_#{variable.to_s}")
              end
            end
            alias_method "superclass_#{variable.to_s}", variable
          end
        end
      end
      
      @subclassable_callbacks
    end
  end
  
  def self.override
    ObjectSpace.each_object(Class) do |object|
      if object.ancestors.include?(SubclassableCallbacks)
        object.class_eval do
          methods = object.subclassable_callbacks
          last_index = object.superclass.ancestors.index(SubclassableCallbacks)
          if last_index && last_index > 0
            superclass_methods = object.superclass.ancestors[0..last_index - 1].map(&:subclassable_callbacks)
            methods = methods.concat(superclass_methods).flatten.uniq
          end 
          methods.each do |name|
            alias_method "subclass_#{name}", "#{name}"
            alias_method "_#{name}", "subclass_#{name}"
            alias_method "#{name}", "superclass_#{name}"
          end
        end
      end
    end
  end
end
