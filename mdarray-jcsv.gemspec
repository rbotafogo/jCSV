# -*- coding: utf-8 -*-

require 'rubygems/platform'
require './version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "MDArray-jCSV (jCSV for short) is the first and only (as far as I know) 
multidimensional CSV reader.  Multidimensional? Yes... jCSV can read multidimensional data, 
also known sometimes as 'panel data'. jCSV is based on Super CSV 
(http://super-csv.github.io/super-csv/index.html), a java CSV library.  According to 
Super CSV web page its motivation is 'for Super CSV is to be 
the foremost, fastest, and most programmer-friendly, free CSV package for Java'. jCSV 
motivation is to bring this view to the Ruby world, and since we are in Ruby, make
it even easier and more programmer-friendly." 
  
  gem.description = <<-EOF 

EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/jCSV/wiki'
  gem.license = 'BSD-2-Clause'

  gem.add_runtime_dependency('mdarray', '~> 0.5')
  gem.add_runtime_dependency('critbit', '~> 0.5')

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
