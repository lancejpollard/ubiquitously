module Ubiquitously
  class User
    attr_accessor :username, :cookies, :agent, :accounts, :cookies_path
    
    def initialize(attributes = {})
      attributes = attributes.symbolize_keys
      
      unless attributes[:agent]
        attributes[:agent] = Mechanize.new
        attributes[:agent].log = Logger.new(STDOUT)
        attributes[:agent].user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
      end
      
      attributes.each do |key, value|
        self.send("#{key.to_s}=", value) if self.respond_to?(key)
      end
      
      raise 'where will cookies be saved??' unless self.cookies_path
      
      self.accounts ||= []
    end
    
    def login(*services)
      load_cookies if File.exists?(self.cookies_path)
      
      services.flatten.each do |name|
        account = "Ubiquitously::#{name.to_s.camelize}::Account".constantize.new(:agent => self.agent)
        if has_cookie_for(name) || !account.respond_to?(:login)
          account.logged_in = true
        else
          account.login
        end
        self.accounts << account unless self.accounts.include?(account)
      end
      
      save_cookies
      
      !self.accounts.blank?
    end
    
    def username_for(service)
      account_for(service).username
    end
    
    def password_for(service)
      account_for(service).password
    end
    
    def account_for(service)
      unless service.is_a?(String)
        service = service.service_name
      end
      login(service)
      self.accounts.detect { |account| account.service_name == service }
    end
    
    def load_cookies(path = self.cookies_path)
      self.agent.cookie_jar.load(path)
    end
    
    def save_cookies(path = self.cookies_path)
      self.agent.cookie_jar.save_as(path)
    end
    
    def has_cookie_for(service)
      !self.agent.cookie_jar.jar.keys.detect do |domain|
        domain.downcase =~ /#{service.to_s}/
      end.blank?
    end
  end
end
