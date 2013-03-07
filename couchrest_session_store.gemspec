# _*_ encoding: utf-8 -*-

Gem::Specification.new do |gem|

  gem.authors = ["Azul"]
  gem.email = ["azul@leap.se"]
  gem.summary = "A Rails Session Store based on CouchRest Model"
  gem.description = gem.summary
  gem.homepage = "http://github.com/azul/couchrest_session_store"

  gem.has_rdoc = true
#  gem.extra_rdoc_files = ["LICENSE"]

  gem.files = %w(README.md Rakefile) + ['lib/couchrest_session_store.rb']
  gem.name = "couchrest_session_store"
  gem.require_paths = ["lib"]
  gem.version = '0.1.1'

  gem.add_dependency "couchrest"
  gem.add_dependency "couchrest_model"
  gem.add_dependency "actionpack"
end
