# A facter fact to determine the installed version of monit.

module Facter::Util::MonitVersion
  class << self
    def get_monit_version
      monit_version = Facter::Util::Resolution.exec('monit -V 2>&1')
      monit_version && monit_version.match(/\d+\.\d+$/).to_s
    end
  end
end

Facter.add(:monit_version) do
  setcode { Facter::Util::MonitVersion.get_monit_version }
end
