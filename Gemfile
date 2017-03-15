source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :unit_tests do
  gem 'rspec-puppet',                                     :require => false
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  # metadata-json-lint > 0.0.11 requires semantic_puppet only available for ruby >= 1.9.3
  gem 'metadata-json-lint', '= 0.0.11',                   :require => false
else
  gem 'metadata-json-lint',                               :require => false
end
  gem 'puppetlabs_spec_helper',                           :require => false
  gem 'puppet-lint',                                      :require => false
  gem 'puppet-lint-absolute_classname-check',             :require => false
  gem 'puppet-lint-alias-check',                          :require => false
  gem 'puppet-lint-empty_string-check',                   :require => false
  gem 'puppet-lint-file_ensure-check',                    :require => false
  gem 'puppet-lint-file_source_rights-check',             :require => false
  gem 'puppet-lint-fileserver-check',                     :require => false
  gem 'puppet-lint-leading_zero-check',                   :require => false
  gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
  gem 'puppet-lint-trailing_comma-check',                 :require => false
  gem 'puppet-lint-undef_in_function-check',              :require => false
  gem 'puppet-lint-unquoted_string-check',                :require => false
  gem 'puppet-lint-variable_contains_upcase',             :require => false
end

group :system_tests do
  gem 'beaker-rspec',  :require => false
  gem 'serverspec',    :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if RUBY_VERSION < '2.0'
  # json 2.x requires ruby 2.0.
  gem 'json',      '~> 1.0',  :require => false
  # json_pure 2.0.2 requires ruby 2.0. Lock to 2.0.1
  gem 'json_pure', '= 2.0.1', :require => false
else
  # rubocop requires ruby >= 2.0
  gem 'rubocop'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
  gem 'rake',  '~> 10.0'
else
  gem 'rake', :require => false
end

# vim:ft=ruby
