module Ubiquitously
  module Command
    class Post < Ubiquitously::Command::Base
      
      def run
        Ubiquitously::Post.new(attributes).save(services)
      end
      
      def options(args)
        option_parser = OptionParser.new do |o|
          o.extend Ubiquitously::Opts
          
          o.banner = "Usage: u.me [command] [service(s)] [options]\n" +
                     "\n" +
                     "Supported Commands:\n#{SUPPORTED_COMMANDS.sort.join(', ')}"
          
          o.section "Authorization options:" do
            username
            password
            consumer_key
            consumer_secret
            access_token
            password
          end
          
          o.section "Common options:" do
            trace
            data
            host
            quiet
            disable_ssl
            request_method
            help
          end
        end

        option_parser.parse!(args)
      end
    
      module Opts

        def section(heading, &block)
          separator ""
          separator heading

          instance_eval(&block)
        end
        
        def consumer_key
          on('-c', '--consumer-key [key]', "Your consumer key (required)") do |key|
            options.consumer_key = key ? key : CLI.prompt_for('Consumer key')
          end
        end
        
        def consumer_secret
          on('-s', '--consumer-secret [secret]', "Your consumer secret (required)") do |secret|
            options.consumer_secret = secret ? secret : CLI.prompt_for('Consumer secret')
          end
        end
        
        def username
          on('-u', '--username [username]', 'Username of account to authorize (required)') do |username|
            options.username = username
          end
        end
      
        def password
          on('-p', '--password [password]', 'Password of account to authorize (required)') do |password|
            options.password = password ? password : CLI.prompt_for('Password')
          end
        end

        def quiet
          on('-q', '--quiet', 'Suppress all output (default: output is printed to STDOUT)') do |quiet|
            options.output = StringIO.new
          end
        end
        
        def title
          
        end
        
        def description
          
        end
        
        def url
          
        end
        
        def tags
          
        end
        
        def help
          on_tail("-h", "--help", "Show this message") do
            CLI.puts self
            exit
          end
        end
      end
    end
  end
end