Dir["#{File.dirname(__FILE__)}/account/*"].each { |c| require c unless File.directory?(c) }

module Ubiquitously
  module Service
    class Account < Ubiquitously::Base
      include Ubiquitously::Account::Restful
      include Ubiquitously::Account::Loggable
      include Ubiquitously::Account::Authorizable
      
      attr_accessor :username, :password
      attr_accessor :agent, :logged_in, :ip
      
      def initialize(attributes = {})
        attributes = attributes.symbolize_keys
        
        attributes[:username] ||= Ubiquitously.key("#{service}.key")
        attributes[:password] ||= Ubiquitously.key("#{service}.secret")
        unless attributes[:agent]
          attributes[:agent] = Mechanize.new
          #attributes[:agent].log = Logger.new(STDOUT)
          attributes[:agent].user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
        end
        
        @logged_in = false
        
        apply attributes
      end
      
    end
  end
end
