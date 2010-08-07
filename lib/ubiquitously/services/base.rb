module Ubiquitously
  module Base
    class Account
      include ActiveModel::Validations
      include ActiveModel::Serialization
      include Ubiquitously::Resourceful
      
      attr_accessor :agent, :username, :password, :logged_in
      
      validates_presence_of :username, :password
      
      def initialize(attributes = {})
        attributes = attributes.symbolize_keys
        
        attributes[:username] ||= Ubiquitously.key("#{service_name}.key")
        attributes[:password] ||= Ubiquitously.key("#{service_name}.secret")
        unless attributes[:agent]
          attributes[:agent] = Mechanize.new
          #attributes[:agent].log = Logger.new(STDOUT)
          attributes[:agent].user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
        end
        
        @logged_in = false
        
        super(attributes)
      end
      
      def logged_in?
        @logged_in == true
      end
    end
    
    class Post
      include ActiveModel::Validations
      include ActiveModel::Serialization
      include Ubiquitously::Resourceful
      
      attr_accessor :title, :url, :description, :tags, :categories
      attr_accessor :image, :rating, :private, :vote, :status
      attr_accessor :service_url, :user
      
      def initialize(attributes = {})
        super(attributes)
        
        raise 'please give me a user' if self.user.blank?
        
        # for httparty
        @auth = {:username => user.username_for(self), :password => user.password_for(self)}
      end
      
      def agent
        user.agent
      end
      
      def inspect
        "#<#{self.class.inspect} @url=#{self.url.inspect} @title=#{self.title.inspect} @description=#{self.description.inspect} @tags=#{self.tags.inspect}>"
      end
      
      def new_record?
        true
      end
      
      def authorize
        user.login(service_name)
      end
      
      def find
        self.class.find(:user => self.user)
      end
      
      def get
        self.class.find(:url => self.url, :user => self.user)
      end
      
      def new_record?
        !self.get.blank?
      end
      
      def url_permutations(url)
        self.class.url_permutations(url)
      end
      
      class << self
        def create(options = {})
          record = new(options)
          record.save
          record
        end
        
        # with and without trailing slash, in case we saved it as one over the other
        def url_permutations(url)
          [url.gsub(/\/$/, ""), url.gsub(/\/$/, "") + "/"]
        end
      end
    end
  end
end
