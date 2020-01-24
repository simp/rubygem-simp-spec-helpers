# rubygem-simp-spec-helpers

rspec-puppet helper methods for SIMP module testing

[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![Build Status](https://travis-ci.org/simp/rubygem-simp-spec-helpers.svg?branch=master)](https://travis-ci.org/simp/rubygem-simp-spec-helpers)
[![Gem](https://img.shields.io/gem/v/simp-spec-helpers.svg)](https://rubygems.org/gems/simp-spec-helpers)
[![Gem_Downloads](https://img.shields.io/gem/dt/simp-spec-helpers.svg)](https://rubygems.org/gems/simp-spec-helpers)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
  * [This gem is part of SIMP](#this-gem-is-part-of-simp)
  * [Features](#features)
* [Setup](#setup)
  * [Gemfile](#gemfile)
  * [Fixtures](#fixtures)
* [Usage](#usage)
  * [In a Unit Test](#in-a-unit-test)
  * [Environment Variables](#environment-variables)
* [Reference](#reference)
* [Limitations](#limitations)
  * [Some versions of bundler fail on FIPS-enabled Systems](#some-versions-of-bundler-fail-on-fips-enabled-systems)
* [Development](#development)
  * [License](#license)
  * [History](#history)

<!-- vim-markdown-toc -->

## Overview

The `simp-spec-helpers` gem provides common rspec tasks to support the SIMP unit testing process.

### This gem is part of SIMP

This gem is part of (the build tooling for) the [System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP), a compliance-management framework built on [Puppet](https://puppetlabs.com/).


### Features

* Customizable RPM packaging based on a Puppet module's [`metadata.json`][metadata.json]
* RPM signing
* Rubygem packaging

## Setup

### .fixtures.yml

You must include the compliance_markup module in your .fixtures.yml:

``` yaml
---
fixtures:
  repositories:
...
  compliance_markup: https://github.com/simp/pupmod-simp-compliance_markup
...
```

NOTE: The helper module sets up the hiera.yml to include the compliance
module.  It should just ignore this if compliance_markup is not included
but, because of a quirk in the testing framework, it doesn't.  When it
tries to compile you will get an error like:

``` ruby
  error during compilation: Evaluation Error: Error while evaluating
    a Function Call, undefined method `load_typed' for nil:NilClass
```
### Gemfile

The Gemfile for your puppet module should have the following included (with updated
versions where necessary):

``` ruby
group :test do
  gem 'puppet', 'puppet', ENV.fetch('PUPPET_VERSION', '~> 5.5')
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'hiera-puppet-helper'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
  gem 'puppet-strings'
  gem 'simp-spec-helpers'
  gem 'simp-rspec-puppet-facts', ENV.fetch('SIMP_RSPEC_PUPPET_FACTS_VERSION', '~> 2.2')
  gem 'simp-rake-helpers', ENV.fetch('SIMP_RAKE_HELPERS_VERSION', '~> 5.9')
  gem 'facterdb'
end
```

## Usage

### In a Unit Test

In your puppet module, create a file spec/spec_helper.rb with the following contents:

``` ruby
require 'simp/rspec-puppet-facts'
include Simp::RspecPuppetFacts
require 'simp/spec_helpers'
include Simp::SpecHelpers
require 'pathname'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
module_name = File.basename(File.expand_path(File.join(__FILE__,'../..')))

global_spec_helper(fixture_path, module_name)

# Get any local methods in spec_helper_local.rb
local_spec_helper = File.join(File.dirname(File.expand_path(__FILE__)),"spec_helper_local.rb")
require_relative 'spec_helper_local' if File.exists?(local_spec_helper)

```
Require the spec helper at the top of each unit test file.

```ruby
require 'spec_helper'
```
Place any module specific configurations or overrides in a  file spec/spec_helper_local.rb.  For example to use RSPEC instead of MOCHA to mock the environment place the following
in spec/spec_helper_local.rb:

``` ruby
RSpec.configure do |c|
  c.mock_framework = :rspec
  c.mock_with :rspec
end
```

### Environment Variables

PUPPET_DEBUG set to anything will enable debug



### Available methods

Besides the global_spec_helper that is used to set up RSPEC the following
methods are installed and can be used in your tests:


#### set_hieradata(hieradata)
 This can be used from inside your spec tests to load custom hieradata within
 any context.

 Example:

 describe 'some::class' do
   context 'with version 10' do
     let(:hieradata){ "#{class_name}_v10" }
     ...
   end
 end

 Then, create a YAML file at spec/fixtures/hieradata/some__class_v10.yaml.

 Hiera will use this file as it's base of information stacked on top of
 'default.yaml' and <module_name>.yaml per the defaults above.

 Note: Any colons (:) are replaced with underscores (_) in the class name.


#### set_environment
 This can be used from inside your spec tests to set the testable environment.
 You can use this to stub out an ENC.

 Example:

 context 'in the :foo environment' do
   let(:environment){:foo}
   ...
 end

#### normalize_compliance_results
  Can be used to removed expected errors in compliance data due to test configuration.
  See pupmod-simp-pupmod for example.

### Limitations


