Dir["#{File.dirname(__FILE__)}/post/*"].each { |c| require c unless File.directory?(c) }

module Ubiquitously
  module Service
    class Post < Ubiquitously::Base
      include Ubiquitously::Post::Ownable
      include Ubiquitously::Post::Postable
      include Ubiquitously::Post::Restful
      include Ubiquitously::Post::Loggable
      
      validates_presence_of :url, :title, :description, :tags
      attr_accessor :token
      
      before :create, :update do
        self.token = tokenize
      end
      after :create, :update do
        self.token = nil
      end
      
      def initialize(attributes = {})
        apply attributes
        
        raise 'please give me a user' if self.user.blank?
        
        self.format ||= "text"
        self.privacy = 0 if self.privacy.nil?
        self.categories ||= []
        self.tags ||= []
        self.upvotes ||= 0
        self.downvotes ||= 0
        
        # for httparty
        @auth = {:username => username, :password => password}
      end
    end
  end
end
