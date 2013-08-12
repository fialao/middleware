# -*- encoding: utf-8 -*-
require File.expand_path('../lib/middleware/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'middleware'
  gem.version       = Middleware::VERSION

  gem.authors       = ['Ondra Fiala', 'Mitchell Hashimoto']
  gem.email         = ['ondra.fiala@gmail.com']
  gem.description   = %q{Generalized implementation of the middleware abstraction for Ruby.}
  gem.summary       = %q{Generalized implementation of the middleware abstraction for Ruby.}
  gem.homepage      = "https://github.com/fialao/middleware"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']


  # Behaviour Driven Development and Testing
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fuubar'

  # Documentation
  gem.add_development_dependency 'yard'
end
