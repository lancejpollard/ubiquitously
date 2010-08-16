Dir["#{File.dirname(__FILE__)}/account/*"].each { |c| require c unless File.directory?(c) }

module Ubiquitously
  module Service
    class Account < Ubiquitously::Base
      include Ubiquitously::Account::Restful
      include Ubiquitously::Account::Loggable
      include Ubiquitously::Account::Authorizable
      
      attr_accessor :username, :password, :credentials
      attr_accessor :logged_in, :ip, :user
      
      def initialize(attributes = {})
        attributes = attributes.symbolize_keys
        
        attributes[:username] = Ubiquitously.key("#{service}.key") if attributes[:username].blank?
        attributes[:password] = Ubiquitously.key("#{service}.secret") if attributes[:password].blank?
        
        if attributes[:username].blank? || attributes[:password].blank?
          raise "Where is the username and password for #{service}?"
        end
        
        @logged_in = false
        
        apply attributes
      end
      
      def credentials
        @credentials ||= {}
      end
      
      def agent
        user.agent
      end
      
      def cookies?
        user.cookies_for?(service)
      end
      
      def credentials?
        !self.credentials.blank?
      end
      
      def access_token
        if uses?(:oauth) && @access_token.blank?
          @access_token = "#{service.camelize}Token".constantize.new
          @access_token.token = credentials["token"]
          @access_token.secret = credentials["secret"]
          @access_token.key = credentials["key"]
        end
        
        @access_token
      end
      
    end
  end
end
