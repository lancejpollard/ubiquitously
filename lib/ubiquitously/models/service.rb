Dir["#{File.dirname(__FILE__)}/service/*"].each { |c| require c unless File.directory?(c) }