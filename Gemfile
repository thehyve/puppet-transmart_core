source ENV['GEM_SOURCE'] || 'https://rubygems.org'

ruby '>= 2.3.0'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 4.0']
gem 'metadata-json-lint'
gem 'semantic_puppet'
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 1.0.0'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet'
gem 'rspec-puppet-facts', '~> 1.7', :require => false
gem 'rubocop'
