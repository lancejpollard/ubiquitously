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
      
      def login
        @logged_in ||= true
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
      # some sites check to see if you're posting duplicate content!
      attr_accessor :image, :rating, :privacy, :vote, :status, :must_be_unique, :captcha
      attr_accessor :service_url, :user
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
      
      def initialize(attributes = {})
        super(attributes)
        
        raise 'please give me a user' if self.user.blank?
        
        self.format ||= "text"
        self.privacy = 0 if self.privacy.nil?
        self.categories ||= []
        self.tags ||= []
        
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
      
      def submit_url
        self.class.submit_url(self)
      end

      def tokenize
        {
          :url => self.url,
          :title => self.title,
          :description => self.description,
          :tags => self.tags.map { |tag| tag.downcase.gsub(/[^a-z0-9]/, " ").squeeze(" ") }.join(", "),
          :categories => self.categories.join(",")
        }
      end
      
      def private?
        privacy == 1 || privacy == "1" || privacy == "private"
      end
      
      def public?
        privacy == 0 || privacy == "0" || privacy == "public"
      end
      
      class << self
        def submit_to(url = nil)
          @submit_to = url if url
          @submit_to
        end

        def submit_url(post)
          post.tokenize.inject(submit_to) do |result, token|
            result.gsub(/:#{token.first}/, token.last)
          end
        end
        
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
