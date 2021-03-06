module Ubiquitously
  class Post < Base
    attr_accessor :url, :title, :description, :tags, :categories, :user, :page, :posts, :format, :extension
    
    def initialize(attributes = {})
      apply attributes
      raise 'please pass Post a User' if self.user.blank?
      self.posts ||= []
    end
    
    def page
      @page ||= Ubiquitously::Page.new(:url => self.url).parse
    end
    
    # create or update
    def save(*services)
      options = services.extract_options!
      postables(*services).map { |post| post.save }
    end
    
    def new_record?(service, &block)
      postables(*service).detect do |post|
        post.new_record?
      end
    end
    
    def postables(*services)
      services = services.flatten.map(&:to_sym)
      result = services.map do |service|
        if service.is_a?(Ubiquitously::Service::Post)
          service
        else
          "Ubiquitously::#{service.to_s.camelize}::Post".constantize.new(
            :user => self.user,
            :url => self.url,
            :title => self.title,
            :description => self.description,
            :tags => self.tags,
            :categories => self.categories,
            :format => self.format,
            :extension => self.extension
          )
        end
      end.uniq
      
      self.posts = self.posts.concat(result)
      
      self.posts.select { |post| services.include?(post.service.to_sym) }
    end
    
    Ubiquitously.services.each do |service|
      define_method service do
        postables(service).first
      end
      
      define_method "#{service.to_s}?" do
        !send(service).new_record?
      end
    end
    
    def inspect
      "#<#{self.class.inspect} @url=#{self.url.inspect} @title=#{self.title.inspect} @description=#{self.description.inspect} @tags=#{self.tags.inspect}>"
    end
    
  end
end
