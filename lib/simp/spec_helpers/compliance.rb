
module Simp; end
module Simp::SpecHelpers; end
module Simp::SpecHelpers::ComplianceMarkup

# This module contains methods use by the compliance markup unit tests.

  # This method receives the results from the compliance map run, the section
  # it  represents and a list of exceptions to ignore.  It will
  # then remove anything it is suppoed to ignore and return the results.
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

