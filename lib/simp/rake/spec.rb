require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'fileutils'
require 'puppetlabs_spec_helper/tasks/beaker'

module Simp; end
module Simp::Rake
  class Spec < ::Rake::TaskLib
    def initialize(base_dir)
      super()

      @base_dir   = base_dir
      @clean_list = []

      ::CLEAN.include( %{#{@base_dir}/log} )
      ::CLEAN.include( %{#{@base_dir}/junit} )
      ::CLEAN.include( %{#{@base_dir}/sec_results} )
      ::CLEAN.include( %{#{@base_dir}/spec/fixtures/inspec_deps} )

      yield self if block_given?

      ::CLEAN.include( @clean_list )

      namespace :spec do
        desc <<-EOM
        EOM
        task :test, [:suite, :nodeset] => ['spec_prep'] do |t,args|
        end
      end
    end
  end
end
