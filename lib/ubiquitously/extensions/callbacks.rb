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
            define_method "implementation_#{variable.to_s}" do; end
            define_method variable do
              send("_run_#{variable.to_s}_callbacks") do
                send("implementation_#{variable.to_s}")
              end
            end
            alias_method "superclass_#{variable.to_s}", variable
          end
        end
      end
      
      @subclassable_callbacks
    end
  end
  
  # ObjectSpace.each_object(Class).to_a for all of them
  def self.override(*classes)
    classes = ObjectSpace.each_object(Class).to_a if classes.blank?
    classes.flatten.each do |object|
      if object.ancestors.include?(SubclassableCallbacks)
        object.class_eval do
          methods = object.subclassable_callbacks
          last_index = object.superclass.ancestors.index(SubclassableCallbacks)
          if last_index && last_index > 0
            superclasses = object.superclass.ancestors[0..last_index - 1]
            superclass_methods = superclasses.select do |clazz|
              clazz.respond_to?(:subclassable_callbacks)
            end.map(&:subclassable_callbacks)
            methods = methods.concat(superclass_methods).flatten.uniq
          end 
          methods.each do |name|
            next unless object.overrides?(name)
            alias_method "subclass_#{name}", "#{name}"
            alias_method "implementation_#{name}", "subclass_#{name}"
            alias_method "#{name}", "superclass_#{name}"
          end
        end
      end
    end
  end
end
