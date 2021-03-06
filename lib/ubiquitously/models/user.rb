module Ubiquitously
  class User < Base
    attr_accessor :username, :name, :email
    attr_accessor :agent, :cookies, :accounts, :storage
    
    def initialize(attributes = {})
      attributes = attributes.symbolize_keys
      
      raise "Please define 'storage'" unless attributes[:storage]
      
      unless attributes[:agent]
        attributes[:agent] = Mechanize.new
        #attributes[:agent].log = Logger.new(STDOUT)
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
    
    def accountables(*items, &block)
      services = items.flatten.map(&:to_s)
      services.each do |service|
        next if self.accounts.detect { |account| account.service == service }
        clazz = "Ubiquitously::#{service.camelize}::Account".constantize
        if block_given?
          self.accounts << yield(clazz)
        else
          self.accounts << clazz.new(:user => self)
        end
      end
      self.accounts.select { |account| services.include?(account.service) }
    end
    
    def account_classes(*items)
      services = items.flatten.map(&:to_s)
      services.map do |service|
        "Ubiquitously::#{service.camelize}::Account".constantize
      end.select { |account| services.include?(account.service) }
    end
    
    def login(*services)
      load
      accountables(*services).map(&:login)
      save
      true
    end
    
    def load
      apply storage.load
    end
    
    def save
      storage.save(cookies, credentials)
    end
    
    def cookies
      self.agent.cookie_jar.jar
    end
    
    def cookies=(hash)
      agent.cookie_jar.jar = hash
    end
    
    def credentials
      self.accounts.inject({}) do |hash, account|
        hash[account.service] = account.credentials.stringify_keys
        hash
      end
    end
    
    def credentials=(hash)
      accountables(hash.keys).each do |account|
        account.credentials.merge!(hash[account.service])
      end
    end
    
    def cookies_for(service)
      name = service_cookie_name(service.to_s)
      result = cookies.keys.detect { |domain| domain.downcase =~ /#{name}/ }
      return nil if result.blank?
      uri = URI.parse("http://#{result}")
      unless agent.cookie_jar.empty?(uri)
        cookies = agent.cookie_jar.cookies(uri)
        cookie = cookies.length > 0 ? cookies.join("; ") : nil
      else
        cookie = nil
      end
    end
    
    def cookies_for?(service)
      !cookies_for(service).blank?
    end
    
    def credentials_for(service)
      credentials[service.to_s]
    end
    
    def credentials_for?(service)
      !credentials_for(service).blank?
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
      accountables(*service).detect { |account| account.service == service }
    end
  end
end
