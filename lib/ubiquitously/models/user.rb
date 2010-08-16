module Ubiquitously
  class User < Base
    attr_accessor :username, :cookies, :agent, :accounts, :cookies_path, :name, :email
    
    def initialize(attributes = {})
      attributes = attributes.symbolize_keys
      
      unless attributes[:agent]
        attributes[:agent] = Mechanize.new
        attributes[:agent].log = Logger.new(STDOUT)
        attributes[:agent].user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
      end
      
      apply attributes
      
      raise 'where will cookies be saved??' unless self.cookies_path
      
      self.accounts ||= []
    end
    
    def login(*services)
      data = load
      services.flatten.each do |name|
        account = "Ubiquitously::#{name.to_s.camelize}::Account".constantize.new(:agent => self.agent)
        if has_cookie_for(name) || !account.respond_to?(:login)
          account.data = data[account.service]
          account.logged_in = true
        else
          account.login
        end
        self.accounts << account unless self.accounts.include?(account)
      end
      
      save
    end
    
    def load
      load_cookies if File.exists?(self.cookies_path)
      load_data
    end
    
    def load_cookies(path = self.cookies_path)
      self.agent.cookie_jar.load(path)
    end
    
    def load_data
      to = "test/config/data.yml"
      File.exists?(to) ? YAML.load_file(to) : {}
    end
    
    def save
      save_cookies
      save_data
      !self.accounts.blank?
    end
    
    def save_cookies(path = self.cookies_path)
      self.agent.cookie_jar.save_as(path)
    end
    
    def save_data
      data = self.accounts.inject({}) do |hash, account|
        hash[account.service] = account.data.stringify_keys
        hash
      end
      
      to = "test/config/data.yml"
      content = File.exists?(to) ? YAML.load_file(to) : {}
      content.merge!(data)
      File.open(to, "w+") { |file| file.puts YAML.dump(content) }
    end
    
    def has_cookie_for(service)
      name = service_cookie_name(service.to_s)
      !self.agent.cookie_jar.jar.keys.detect do |domain|
        domain.downcase =~ /#{name}/
      end.blank?
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
      login service
      self.accounts.detect { |account| account.service == service }
    end
  end
end
