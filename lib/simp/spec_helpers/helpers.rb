module Simp; end

module Simp::SpecHelpers::Helpers

# This can be used from inside your spec tests to set the testable environment.
# You can use this to stub out an ENC.
#

# Example:
#
# context 'in the :foo environment' do
#   let(:environment){:foo}
#   ...
# end
#
def set_environment(environment = :production)
    RSpec.configure { |c| c.default_facts['environment'] = environment.to_s }
end

# This can be used from inside your spec tests to load custom hieradata within
# any context.
#
# Example:
#
# describe 'some::class' do
#   context 'with version 10' do
#     let(:hieradata){ "#{class_name}_v10" }
#     ...
#   end
# end
#
# Then, create a YAML file at spec/fixtures/hieradata/some__class_v10.yaml.
#
# Hiera will use this file as it's base of information stacked on top of
# 'default.yaml' and <module_name>.yaml per the defaults above.
#
# Note: Any colons (:) are replaced with underscores (_) in the class name.

def set_hieradata(hieradata)
    RSpec.configure { |c| c.default_facts['custom_hiera'] = hieradata }
end

def normalize_compliance_results(compliance_profile_data, section, exceptions)
  normalized = Marshal.load(Marshal.dump(compliance_profile_data))
  if section == 'non_compliant'
    exceptions['non_compliant'].each do |resource,params|
      params.each do |param|
        if normalized['non_compliant'].key?(resource) &&
            normalized['non_compliant'][resource]['parameters'].key?(param)
          normalized['non_compliant'][resource]['parameters'].delete(param)
          if normalized['non_compliant'][resource]['parameters'].empty?
            normalized['non_compliant'].delete(resource)
          end
        end
      end
    end
  else
    normalized[section].delete_if do |item|
      rm = false
      Array(exceptions[section]).each do |allowed|
        if allowed.is_a?(Regexp)
          if allowed.match?(item)
            rm = true
            break
          end
        else
          rm = (allowed == item)
        end
      end
      rm
    end
  end

  normalized
end

end
