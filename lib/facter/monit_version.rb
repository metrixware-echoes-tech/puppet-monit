if Facter::Util::Resolution.which('monit')
  version = Facter::Util::Resolution.exec('monit -V 2>&1').match(/\d+\.\d+$/).to_s

  if version
    Facter.add('monit_version') do
      setcode do
        version
      end
    end
  end
end
