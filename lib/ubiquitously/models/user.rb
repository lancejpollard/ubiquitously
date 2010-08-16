module Ubiquitously
  class User < Base
    attr_accessor :username, :name, :email
    attr_accessor :agent, :cookies, :accounts, :storage
    
    def initialize(attributes = {})
      attributes = attributes.symbolize_keys
      
      raise "Please define 'storage'" unless attributes[:storage]
      
      unless attributes[:agent]
        attributes[:agent] = Mechanize.new
        attributes[:agent].log = Logger.new(STDOUT)
        attributes[:agent].user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
      end
      
      if attributes[:storage].is_a?(String)
        attributes[:storage] = Ubiquitously::Storage::FileSystem.new(attributes[:storage])
      end
      
      apply attributes
    end
    
    def accounts
      @accounts ||= []
    end
    
    def accountables(*items)
      items.flatten.inject(self.accounts) do |accounts, item|
        next if accounts.detect { |account| account.service == item.to_s }
        accounts << "Ubiquitously::#{name.to_s.camelize}::Account".constantize.new(
          :user => self
        )
        accounts
      end
    end
    
    def login(*services)
      load
      accountables(*services).map(&:login)
      save
    end
    
    def load
      hash = storage.load
      agent.cookie_jar.jar = hash[:cookies]
      accountables(hash[:credentials]).each do |account|
        account.credentials.merge!(hash[account.service.to_s])
      end
    end
    
    def save
      storage.save(cookies, credentials)
    end
    
    def cookies
      self.agent.cookie_jar.jar
    end
    
    def credentials
      self.accounts.inject({}) do |hash, account|
        hash[account.service] = account.credentials.stringify_keys
        hash
      end
    end
    
    def cookies_for?(service)
      name = service_cookie_name(service.to_s)
      !cookies.keys.detect { |domain| domain.downcase =~ /#{name}/ }.blank?
    end
    
    def service_cookie_name(service)
      return service.gsub("_", "_?") unless service == "dzone_snippets"
      return "dzone"
    end
    
    def username_for(service)
      account_for(service).username
    end
    
    def password_for(service)
      account_for(service).password
    end
    
    def account_for(service)
      service = service.service unless service.is_a?(String)
      self.accounts.detect { |account| account.service == service }
    end
  end
end
