$: << File.expand_path( '../lib/', __FILE__ )

require 'rubygems'
require 'rake/clean'
require 'fileutils'
require 'find'
require 'rspec/core/rake_task'
require 'simp/rake/spec'

@package='simp-spec-helpers'
@rakefile_dir=File.dirname(__FILE__)

Simp::Rake::Spec.new(@rakefile_dir)

CLEAN.include "#{@package}-*.gem"
CLEAN.include 'pkg'
CLEAN.include 'dist'
CLEAN.include '.vendor'
Find.find( @rakefile_dir ) do |path|
  if File.directory? path
    CLEAN.include path if File.basename(path) == 'tmp'
  else
    Find.prune
  end
end


desc 'Ensure gemspec-safe permissions on all files'
task :chmod do
  gemspec = File.expand_path( "#{@package}.gemspec", @rakefile_dir ).strip
  spec = Gem::Specification::load( gemspec )
  spec.files.each do |file|
    FileUtils.chmod 'go=r', file
  end
end

desc 'special notes about these rake commands'
task :help do
  puts %Q{
== environment variables ==
SIMP_RPM_BUILD     when set, alters the gem produced by pkg:gem to be RPM-safe.
                   'pkg:gem' sets this automatically.
  }
end

desc "Run spec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/lib/**/*_spec.rb'
end

desc %q{run all RSpec tests (alias of 'spec')}
task :test => :spec

# vim: syntax=ruby
