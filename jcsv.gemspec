# -*- coding: utf-8 -*-

require 'rubygems/platform'
require './version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "jCSV is a fast and flexible CSV parser for JRuby.  Based on uniVocity parser, 
considered by www.xxx.xxx. the fastest CSV reader for Java."
  
  gem.description = <<-EOF 

EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/jCSV/wiki'
  gem.license = 'Apache'

  gem.add_runtime_dependency('mdarray', '~> 0.5')

  gem.add_development_dependency('CodeWriter', '~> 0.1')
  gem.add_development_dependency('shoulda', "~> 3.5")
  gem.add_development_dependency('simplecov', "~> 0.11")
  gem.add_development_dependency('yard', "~> 0.8")
  gem.add_development_dependency('kramdown', "~> 1.0")
  
  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
