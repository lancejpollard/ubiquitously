module Ubiquitously
  module Base
    class User
      include ActiveModel::Validations
      include ActiveModel::Serialization
      include Ubiquitously::Resourceful
      
      attr_accessor :agent, :username, :password
      
      validates_presence_of :username, :password
      
      def initialize(attributes = {})
        attributes = attributes.symbolize_keys
        
        attributes[:username] ||= Ubiquitously.key("#{service_name}.key")
        attributes[:password] ||= Ubiquitously.key("#{service_name}.secret")
        
        @logged_in = false
        
        super(attributes)
        
        self.agent = Mechanize.new
        # self.agent.log = Logger.new(STDOUT)
        self.agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
      end
      
      def logged_in?
        @logged_in == true
      end
    end
    
    class Post
      include ActiveModel::Validations
      include ActiveModel::Serialization
      include Ubiquitously::Resourceful
      
      attr_accessor :title, :url, :description, :tags, :categories, :service_url, :user
      
      def user
        @user ||= "Ubiquitously::#{service_name.titleize}::User".constantize.new
      end
      
      def agent
        user.agent
      end
      
      class << self
        def create(options = {})
          record = new(options)
          record.save
          record
        end
      end
    end
  end
end
