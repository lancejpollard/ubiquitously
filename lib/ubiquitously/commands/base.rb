module Ubiquitously
  module Command
    class Base
      class << self
        def run(args)
          new(args).run
        end
      end
      
      attr_accessor :services, :attributes
      
      def write(to, content = "")
        File.open(to, "w+") { |file| file.puts content }
      end
      
      def configure(folder)
        Dir.mkdir(folder) unless File.exists?(folder)
        secrets_path     = File.join(folder, "secrets.yml")
        tokens_path      = File.join(folder, "tokens.yml")
        
        # usernames and passwords for post services
        unless File.exists?(secrets_path)
          secrets = "# #{secrets_path}, in your home directory\n"
          secrets << "# write your username and passwords for the different services\n"
          secrets << "# as necessary.\n\n"
          Ubiquitously.services.each do |service|
            secrets << "#{service}:\n"
            secrets << "  key: your_username\n"
            secrets << "  secret: your_password\n"
          end
          write(secrets_path, secrets)
          system("open", secrets_path)
          puts "Please configure your service username and passwords and rerun your command."
          exit
        end
        
        Ubiquitously.configure(secrets_path)
        
        # oauth keys and secrets from services
        unless File.exists?(tokens_path)
          tokens = "# #{tokens_path}, in your home directory\n"
          tokens << "# Get app key/secrets from the oauth providers below\n"
          tokens << "# and fill them out as desired.\n\n"
          tokens << "services:\n"
          Passport.services.each do |service|
            tokens << "  #{service}:\n"
            tokens << "    key: app_key\n"
            tokens << "    secrets: app_secret\n"
          end
          write(tokens_path, tokens)
          system("open", tokens_path)
          puts "Please configure your oauth keys and secrets and rerun your command."
          exit
        end
        
        Passport.configure(tokens_path)
      end
      
      def main_folder
        File.expand_path("~/.u.me")
      end
      
      def show
        tmp = File.join(main_folder, "post.yml")
        if File.exists?(tmp)
          post = IO.read(tmp)
        else
          post = ""
          post << "services: \n"
          post << "url: \n"
          post << "title: \n"
          post << "description: \n"
          post << "tags: \n"
          write(tmp, post)
        end
        system("open", tmp)
        require 'timeout'
        begin
          Timeout::timeout(30) {
            puts "Will timeout in 30 seconds. Press Enter when you're ready."
            STDIN.gets.chomp
            self.attributes = YAML.load_file(tmp).symbolize_keys
            #File.delete(tmp) if File.exists?(tmp)
            # Something that should be interrupted if it takes too much time...
          }
        rescue Exception => e
          puts e.inspect
          puts "Resubmit post with same command.  Finished process executing to clean things up."
          exit
        end
        
      end
      
      def initialize(args)
        configure(main_folder)
        self.services = []
        self.attributes = {}
        show if args.blank?
        self.services << args.shift while args.length > 0 && args.first !~ /^-/
        self.services << attributes.delete(:services) if attributes.has_key?(:services)
        self.attributes[:title] = self.services.pop unless Ubiquitously.include?(self.services.last)
        self.attributes = parse_options(args, attributes)
        
        self.attributes.each do |key, value|
          self.send("#{key.to_s}=", value) if self.respond_to?(key)
        end 
      end
      
      def parse_options(attributes)
        
      end
      
      def run
        
      end
    end
  end
end
