require 'rubygems'
require 'open-uri'
require 'cgi'
require 'rack/utils'
require 'yaml'
require 'json'
require 'mechanize'
require 'highline/import'
require 'logger'
require 'httparty'
require 'active_support'
require 'active_model'
require 'passport'

this = File.dirname(__FILE__)

module Ubiquitously
  class SettingsError < StandardError; end
  class AuthenticationError < StandardError; end
  class DuplicateError < StandardError; end
  class RecordInvalid < StandardError; end
  class CommandInvalid < StandardError; end
  
  class << self
    attr_accessor :config, :logger
    
    def run(args)
      command = args.shift
      if command =~ /(secrets|tokens|cookies|credentials)/
        system("open", File.expand_path("~/.u.me/#{$1}.yml"))
        exit
      end
      unless command =~ /(?:post|user)/
        message = "\nUbiquitously command must be for either 'post' or 'user', e.g.:\n"
        message << "u.me post twitter 'Working with Rails today...'"
        raise CommandInvalid.new(message)
      end
      "Ubiquitously::Command::#{command.camelize}".constantize.run(args)
    end
    
    def configure(value)
      self.config = value.is_a?(String) ? YAML.load_file(value) : value
    end
    
    def logger
      unless @logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end
      
      @logger
    end
    
    def debug?
      logger.debug?
    end
    
    def key(path)
      result = self.config
      path.to_s.split(".").each { |node| result = result[node.to_s] if result }
      result.to_s
    end
    
    def include?(service)
      services.include?(service)
    end
    
    def credentials(service)
      result = key(service)
      unless result && result.has_key?("key") && result.has_key?("secret")
        raise SettingsError.new("Please specify both a key and secret for ':#{service}'")
      end
      result
    end
    
    def services
      Dir.entries(File.dirname(__FILE__) + '/ubiquitously/services')[2..-1].collect do |service|
        service = File.basename(service).split(".").first
      end
    end
  end
end

Dir["#{this}/ubiquitously/extensions/*"].each { |c| require c }
Dir["#{this}/ubiquitously/models/*"].each { |c| require c unless File.directory?(c) }
Dir["#{this}/ubiquitously/services/*"].each { |c| require c unless File.directory?(c) }
Dir["#{this}/ubiquitously/support/*"].each { |c| require c unless File.directory?(c) }
Dir["#{this}/ubiquitously/commands/*"].each { |c| require c unless File.directory?(c) }

overrides = Dir["#{this}/ubiquitously/services/*"].map do |file|
  name = File.basename(file).split(".").first.camelize
  ["Ubiquitously::#{name}::Account".constantize, "Ubiquitously::#{name}::Post".constantize]
end.flatten

SubclassableCallbacks.override(*overrides)