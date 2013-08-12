# SimpleCov and https://coveralls.io
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

# Include Middleware library
require File.join(File.dirname(__FILE__), '../', 'lib/middleware')
