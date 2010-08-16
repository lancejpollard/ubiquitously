module Ubiquitously
  module Storage
    class Base
      def initialize(*)
        
      end
      
      def save(cookies, credentials)
        
      end
      
      def load
        
      end
    end
    
    class FileSystem < Base
      attr_accessor :path
      
      def initialize(path)
        self.path = path
      end
      
      def save(cookies, credentials)
        write("#{path}/cookies.yml", cookies)
        write("#{path}/credentials.yml", credentials)
      end
      
      def load
        {
          :cookies => read("#{path}/cookies.yml"),
          :credentials => read("#{path}/credentials.yml")
        }
      end
      
      def read(path)
        result = File.exists?(path) ? YAML.load_file(path) : {}
        result = {} unless result.is_a?(Hash)
        result
      end
      
      def write(path, content)
        File.open(path, "w+") { |file| file.puts YAML.dump(content) }
      end
    end
    
    class ActiveRecord < Base
      attr_accessor :record, :cookies_attribute, :credentials_attribute
      
      def initialize(record, cookies_attribute, credentials_attribute)
        self.record = record
        self.cookies_attribute = cookies_attribute
        self.credentials_attribute = credentials_attribute
      end
      
      def save(cookies, credentials)
        record.update_attributes(
          cookies_attribute => cookies,
          credentials_attribute => credentials
        )
      end
      
      def load
        {
          :cookies => record.read_attribute(cookies_attribute),
          :credentials => record.read_attribute(credentials_attribute)
        }
      end
    end
  end
end
