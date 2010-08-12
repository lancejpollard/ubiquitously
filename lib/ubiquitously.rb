require 'rubygems'
require 'open-uri'
require 'cgi'
require 'yaml'
require 'json'
require 'nokogiri'
require 'mechanize'
require 'highline/import'
require 'logger'
require 'active_support'
require 'active_model'

this = File.dirname(__FILE__)
require "#{this}/ext"
Dir["#{this}/ubiquitously/mixins/*"].each { |c| require c }
require "#{this}/ubiquitously/services/base"

module Ubiquitously
  class SettingsError < StandardError; end
  class AuthenticationError < StandardError; end
  class DuplicateError < StandardError; end
  class RecordInvalid < StandardError; end

  class << self
    attr_accessor :config
    
    def configure(value)
      self.config = value.is_a?(String) ? YAML.load_file(value) : value
    end
    
    def key(path)
      result = self.config
      path.to_s.split(".").each { |node| result = result[node.to_s] if result }
      result.to_s
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

require "#{this}/ubiquitously/user"
require "#{this}/ubiquitously/page"
require "#{this}/ubiquitously/post"
Dir["#{this}/ubiquitously/services/*"].each { |c| require c unless File.directory?(c) }
