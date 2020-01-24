require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'

module Simp; end

module Simp::SpecHelpers; end

# These modules are the modules that used to be located
# in every modules spec/spec_helpers.rb.

module Simp::SpecHelpers::Helpers

  # This method does basic RSPEC configuration that common
  # to most SIMP modules for unit tests.
  # This code was originally in each module's spec/spec_helper.rb.
  # Environment Variables that can be used to change its behavior:
  #   PUPPET_DEBUG  set to anything will enable puppet debug
  #   SIMP_SPEC_MOCK_ENV set to "rspec" will mock with rpec otherwise it will
  #                       mock with mocha
  def global_spec_helper(fixture_path, module_name)

    require 'yaml'
    require 'fileutils'

    if ENV['PUPPET_DEBUG']
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
    end

    default_hiera_config =<<~EOM
      ---
      version: 5
      hierarchy:
        - name: SIMP Compliance Engine
          lookup_key: compliance_markup::enforcement
          options:
            enabled_sce_versions: [2]
        - name: Custom Test Hiera
          path: "%{custom_hiera}.yaml"
        - name: "%{module_name}"
          path: "%{module_name}.yaml"
        - name: Common
          path: default.yaml
      defaults:
        data_hash: yaml_data
        datadir: "stub"
    EOM

    if not File.directory?(File.join(fixture_path,'hieradata')) then
      FileUtils.mkdir_p(File.join(fixture_path,'hieradata'))
    end

    if not File.directory?(File.join(fixture_path,'modules',module_name)) then
      FileUtils.mkdir_p(File.join(fixture_path,'modules',module_name))
    end

    RSpec.configure do |c|
      # If nothing else...
      c.default_facts = {
        :production => {
          #:fqdn           => 'production.rspec.test.localdomain',
          :path           => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
          :concat_basedir => '/tmp'
        }
      }

      c.mock_framework = :rspec
      c.mock_with  :mocha

      c.module_path = File.join(fixture_path, 'modules')
      c.manifest_dir = File.join(fixture_path, 'manifests')

      c.hiera_config = File.join(fixture_path,'hieradata','hiera.yaml')

      # Useless backtrace noise
      backtrace_exclusion_patterns = [
        /spec_helper/,
        /gems/
      ]

      if c.respond_to?(:backtrace_exclusion_patterns)
        c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
      elsif c.respond_to?(:backtrace_clean_patterns)
        c.backtrace_clean_patterns = backtrace_exclusion_patterns
      end

      c.before(:all) do
        data = YAML.load(default_hiera_config)
        data.keys.each do |key|
          next unless data[key].is_a?(Hash)

          if data[key][:datadir] == 'stub'
            data[key][:datadir] = File.join(fixture_path, 'hieradata')
          elsif data[key]['datadir'] == 'stub'
            data[key]['datadir'] = File.join(fixture_path, 'hieradata')
          end
        end

        File.open(c.hiera_config, 'w') do |f|
          f.write data.to_yaml
        end
      end

      c.before(:each) do
        @spec_global_env_temp = Dir.mktmpdir('simpspec')

        if defined?(environment)
          set_environment(environment)
          FileUtils.mkdir_p(File.join(@spec_global_env_temp,environment.to_s))
        end

        # ensure the user running these tests has an accessible environmentpath
        Puppet[:environmentpath] = @spec_global_env_temp
        Puppet[:user] = Etc.getpwuid(Process.uid).name
        Puppet[:group] = Etc.getgrgid(Process.gid).name
        Puppet[:digest_algorithm] = 'sha256'

        # sanitize hieradata
        if defined?(hieradata)
          set_hieradata(hieradata.gsub(':','_'))
        elsif defined?(class_name)
          set_hieradata(class_name.gsub(':','_'))
        end
      end

      c.after(:each) do
        # clean up the mocked environmentpath
        FileUtils.rm_rf(@spec_global_env_temp)
        @spec_global_env_temp = nil
      end
    end

    Dir.glob("#{RSpec.configuration.module_path}/*").each do |dir|
      begin
        Pathname.new(dir).realpath
      rescue
        fail "ERROR: The module '#{dir}' is not installed. Tests cannot continue."
      end
    end
  end

  # This can be used from inside your spec tests to set the testable environment.
  # You can use this to stub out an ENC.
  #
  def set_environment(environment = :production)
      RSpec.configure { |c| c.default_facts['environment'] = environment.to_s }
  end

  # This can be used from inside your spec tests to load custom hieradata within
  # any context.
  #
  def set_hieradata(hieradata)
      RSpec.configure { |c| c.default_facts['custom_hiera'] = hieradata }
  end

end
