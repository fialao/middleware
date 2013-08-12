# Include middleware files.
Dir.glob(File.join(File.dirname(__FILE__), 'middleware/**', '*.rb')) { |f| require f }
