module Simp; end
module Simp::SpecHelpers
  require 'puppetlabs_spec_helper/module_spec_helper'
  require 'rspec-puppet'

  require 'simp/spec_helpers/helpers'
  include Simp::SpecHelpers::Helpers

  require 'simp/spec_helpers/compliance'
  include Simp::SpecHelpers::ComplianceMarkup

end


