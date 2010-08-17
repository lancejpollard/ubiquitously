module Ubiquitously
  module Command
    class Post < Ubiquitously::Command::Base
      
      def run
        user = Ubiquitously::User.new(:storage => ".")
        user.accountables(services) do |account|
          account = account.new(
            :user => user,
            :username => attributes[:username],
            :password => attributes[:password]
          )
        end
        Ubiquitously::Post.new(attributes.merge(:user)).save(services)
      end
      
      def required(attributes)
        missing = %w(description username password).delete_if { |i| !attributes[i.to_sym].blank? }
        unless missing.blank?
          raise CommandInvalid.new("Missing arguments for post: #{missing.join(", ")}")
        end
        attributes
      end
      
      def parse_options(args)
        attributes = {}
        option_parser = OptionParser.new do |o|
          o.extend Ubiquitously::Command::Post::Opts
          o.options(attributes)
          
          o.banner = "Usage: u.me [command] [service(s)] [options]\n" +
                     "\n" +
                     "Supported Commands:\n#{Ubiquitously.services.sort.join(', ')}"
          
          o.section "Post attributes:" do
            url
            title
            description
            tags
            username
            password
          end
        end
        
        option_parser.parse!(args)
        
        required attributes
      end
      
      module Opts
        
        def options(value = nil)
          @options = value if value
          @options
        end
        
        def section(heading, &block)
          separator ""
          separator heading
          
          instance_eval(&block)
        end
        
        def url
          on('-u', '--url URL', "Post url (required)") do |url|
            options[:url] = url
          end
        end
        
        def title
          on('-l', '--title TITLE', "Post title (required)") do |title|
            options[:title] = title
          end
        end
        
        def tags
          on('-t', '--tags TAGS', "Post tags (required)") do |tags|
            options[:tags] = tags.split(/,(?:\s+)?/)
          end
        end
        
        def description
          on('-d', '--description DESCRIPTION', "Post description (required)") do |description|
            options[:description] = description
          end
        end
        
        def username
          on('-U', '--username [username]', "Username for service") do |username|
            options[:username] = username
          end
        end

        def password
          on('-P', '--password [password]', "Password for service") do |password|
            options[:password] = password
          end
        end
        
        def help
          on_tail("-h", "--help", "Show this message") do
            exit
          end
        end
      end
    end
  end
end