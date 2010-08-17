Dir["#{File.dirname(__FILE__)}/post/*"].each { |c| require c unless File.directory?(c) }

module Ubiquitously
  module Service
    class Post < Ubiquitously::Base
      include Ubiquitously::Ownable::Post
      include Ubiquitously::Postable::Post
      include Ubiquitously::Restful::Post
      include Ubiquitously::Loggable::Post
      
      #validates_presence_of :title, :description, :tags
      attr_accessor :token
      attr_accessor :title, :url, :description, :tags, :categories, :remote, :service_id
      # some sites check to see if you're posting duplicate content!
      # perhaps "vote" can mean "favorite" also
      attr_accessor :image, :rating, :privacy, :vote, :status, :must_be_unique, :captcha
      attr_accessor :service_url, :user, :upvotes, :downvotes
      # the application that automates! ("Posted by TweetMeme")
      attr_accessor :source, :source_url
      # kind == regular, link, quote, photo, conversation, video, audio, answer
      attr_accessor :kind
      # plain, html, markdown
      attr_accessor :format, :extension
      # max 55 chars, for custom url if possible
      attr_accessor :slug
      # published, draft, submission, queue
      attr_accessor :state
      
      before_create { self.token = tokenize }
      before_update { self.token = tokenize }
      after_create { self.token = nil }
      after_update { self.token = nil }
      
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
      
      def remote
        @remote ||= self.class.find(:url => self.url, :user => self.user)
      end
      
      def access_token
        user.account_for(self).access_token
      end
    end
  end
end
