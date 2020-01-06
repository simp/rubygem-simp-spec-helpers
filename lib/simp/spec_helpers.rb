require 'bundler'
require 'rspec'

module Simp; end

module Simp::SpecHelpers

  # Stealing this from the Ruby 2.5 Dir::Tmpname workaround from Rails
  def self.tmpname
    t = Time.new.strftime("%Y%m%d")
    "simp-spec-helpers-#{t}-#{$$}-#{rand(0x100000000).to_s(36)}.tmp"
  end

end
