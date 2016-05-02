require 'rake/tasklib'
require File.expand_path('lib/simp/spec/helpers/version.rb', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'simp-spec-helpers'
  s.date        = Date.today.to_s
  s.summary     = "SIMP spec helpers"
  s.description = "simp-spec-helpers provides common methods for SIMP spec tests."
  s.version     = Simp::Spec::Helpers::Version
  s.email       = 'simp@simp-project.org'
  s.homepage    = 'https://github.com/simp/rubygem-simp-spec-helpers'
  s.license     = 'Apache-2.0'
  s.authors     = [
    "Chris Tessmer",
    "Nick Markowski"
  ]
  s.metadata    = {
    'issue_tracker' => 'https://simp-project.atlassian.net'
  }

  s.add_runtime_dependency 'bundler',                   '~> 1.0'
  s.add_runtime_dependency 'rake',                      '~> 10.0'
  s.add_runtime_dependency 'coderay',                   '~> 1.0'
  s.add_runtime_dependency 'puppet',                    '>= 3.0'
  s.add_runtime_dependency 'puppet-lint',               '~> 1.0'
  s.add_runtime_dependency 'puppetlabs_spec_helper',    '~> 0.0'
  s.add_runtime_dependency 'parallel',                  '~> 1.0'
  s.add_runtime_dependency 'simp-rspec-puppet-facts',   '~> 1.0'
  s.add_runtime_dependency 'puppet-blacksmith',         '~> 3.3'
  s.add_runtime_dependency 'simp-beaker-helpers',       '~> 1.0'
  s.add_runtime_dependency 'parallel_tests',            '~> 2.4'
  s.add_runtime_dependency 'r10k',                      '~> 2.2'
  s.add_runtime_dependency 'pager'
  s.add_runtime_dependency 'hiera-puppet-helper',       '~> 1.0'

  s.files       = Dir[
                'Rakefile',
                'CHANGELOG*',
                'CONTRIBUTING*',
                'LICENSE*',
                'README*',
                '{bin,lib,spec}/**/*',
                'Gemfile',
                'Guardfile',
                '.gitignore',
                '.rspec',
                '.travis.yml',
  ] & `git ls-files -z .`.split("\0")
end
