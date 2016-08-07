require 'spec_helper'
describe 'monit' do
  platforms = {
    'debian6' =>
      { :osfamily          => 'Debian',
        :release           => '6.0',
        :majrelease        => '6',
        :lsbdistcodename   => 'squeeze',
        :packages          => 'monit',
        :monit_version     => '5',
        :default_content   => 'startup=1',
        :config_file       => '/etc/monit/monitrc',
        :service_hasstatus => false,
      },
    'debian7' =>
      { :osfamily          => 'Debian',
        :release           => '7.0',
        :majrelease        => '7',
        :lsbdistcodename   => 'wheezy',
        :packages          => 'monit',
        :monit_version     => '5',
        :default_content   => 'START=yes',
        :config_file       => '/etc/monit/monitrc',
        :service_hasstatus => true,
      },
    'el5' =>
      { :osfamily          => 'RedHat',
        :release           => '5.0',
        :majrelease        => '5',
        :lsbdistcodename   => nil,
        :packages          => 'monit',
        :monit_version     => '4',
        :config_file       => '/etc/monit.conf',
        :service_hasstatus => true,
      },
    'el6' =>
      { :osfamily          => 'RedHat',
        :release           => '6.0',
        :majrelease        => '6',
        :lsbdistcodename   => nil,
        :packages          => 'monit',
        :monit_version     => '5',
        :config_file       => '/etc/monit.conf',
        :service_hasstatus => true,
      },
    'el7' =>
      { :osfamily          => 'RedHat',
        :release           => '7.0',
        :lsbdistcodename   => nil,
        :majrelease        => '7',
        :packages          => 'monit',
        :monit_version     => '5',
        :config_file       => '/etc/monitrc',
        :service_hasstatus => true,
      },
    'ubuntu1004' =>
      { :osfamily          => 'Debian',
        :release           => '10.04',
        :majrelease        => '10',
        :lsbdistcodename   => 'lucid',
        :packages          => 'monit',
        :monit_version     => '5',
        :default_content   => 'startup=1',
        :config_file       => '/etc/monit/monitrc',
        :service_hasstatus => false,
      },
    'ubuntu1204' =>
      { :osfamily          => 'Debian',
        :release           => '12.04',
        :majrelease        => '12',
        :lsbdistcodename   => 'precise',
        :packages          => 'monit',
        :monit_version     => '5',
        :default_content   => 'START=yes',
        :config_file       => '/etc/monit/monitrc',
        :service_hasstatus => true,
      },
    'ubuntu1404' =>
      { :osfamily          => 'Debian',
        :release           => '14.04',
        :majrelease        => '14',
        :lsbdistcodename   => 'trusty',
        :packages          => 'monit',
        :monit_version     => '5',
        :default_content   => 'START=yes',
        :config_file       => '/etc/monit/monitrc',
        :service_hasstatus => true,
      },
  }

  describe 'with default values for parameters on' do
    platforms.sort.each do |k, v|
      context "#{k}" do
        let :facts do
          { :lsbdistcodename           => v[:lsbdistcodename],
            :osfamily                  => v[:osfamily],
            :kernelrelease             => v[:release],        # Solaris specific
            :monit_version             => v[:monit_version],
            :operatingsystemrelease    => v[:release],        # Linux specific
            :operatingsystemmajrelease => v[:majrelease],
          }
        end

        # If support for another osfamily is added, this should be specified
        # per platform in the platforms hash.
        if v[:osfamily] == 'RedHat'
          config_dir = '/etc/monit.d'
        elsif v[:osfamily] == 'Debian'
          config_dir = '/etc/monit/conf.d'
        else
          fail 'unsupported osfamily detected'
        end

        it { should compile.with_all_deps }

        it { should contain_class('monit') }

        if v[:packages].class == Array
          v[:packages].each do |pkg|
            it do
              should contain_package(pkg).with({
                'ensure'   => 'present',
                'provider' => nil,
              })
            end
          end
        else
          it do
            should contain_package(v[:packages]).with({
              'ensure'   => 'present',
              'provider' => nil,
            })
          end
        end

        it do
          should contain_file('/var/lib/monit').with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          })
        end

        it do
          should contain_file('monit_config_dir').with({
            'ensure'  => 'directory',
            'path'    => config_dir,
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'purge'   => false,
            'recurse' => false,
            'require' => 'Package[monit]',
          })
        end

        it do
          should contain_file('monit_config').with({
            'ensure'  => 'file',
            'path'    => v[:config_file],
            'owner'   => '0',
            'group'   => '0',
            'mode'    => '0600',
            'require' => 'Package[monit]',
          })
        end

        monit_config_fixture = File.read(fixtures("monitrc.#{k}"))
        it { should contain_file('monit_config').with_content(monit_config_fixture) }

        if v[:osfamily] == 'Debian'
          it { should contain_file('/etc/default/monit').with({ 'before' => 'Service[monit]' }) }

          it { should contain_file('/etc/default/monit').with_content(/^#{v[:default_content]}$/) }
        else
          it { should_not contain_file('/etc/default/monit') }
        end

        it do
          should contain_service('monit').with({
            'ensure'     => 'running',
            'name'       => 'monit',
            'enable'     => true,
            'hasrestart' => true,
            'hasstatus'  => v[:service_hasstatus],
            'subscribe'  => [
              'File[/var/lib/monit]',
              'File[monit_config_dir]',
              'File[monit_config]',
            ]
          })
        end
      end
    end
  end

  describe 'parameter functionality' do
    let(:facts) do
      {
        :osfamily        => 'Debian',
        :lsbdistcodename => 'squeeze',
        :monit_version   => '4',
      }
    end

    context 'when check_interval is set to valid integer <242>' do
      let(:params) { { :check_interval => 242 } }
      it { should contain_file('monit_config').with_content(/^set daemon 242$/) }
    end

    context 'when httpd is set to valid bool <true>' do
      let(:params) { { :httpd => true } }
      content = <<-END.gsub(/^\s+\|/, '')
        |set httpd port 2812 and
        |   use address localhost
        |   allow 0.0.0.0/0.0.0.0
        |   allow admin:monit
      END
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when httpd_* params are set to valid values' do
      let(:params) do
        {
          :httpd          => true,
          :httpd_port     => 2420,
          :httpd_address  => 'otherhost',
          :httpd_user     => 'tester',
          :httpd_password => 'Passw0rd',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |set httpd port 2420 and
        |   use address otherhost
        |   allow 0.0.0.0/0.0.0.0
        |   allow tester:Passw0rd
      END
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when manage_firewall and http are set to valid bool <true>' do
      # kernel fact is needed for ::firewall
      let(:pre_condition) { ['include ::firewall'] }
      let(:facts) do
        {
          :operatingsystem        => 'Debian',
          :operatingsystemrelease => '6',
          :osfamily               => 'Debian',
          :lsbdistcodename        => 'squeeze',
          :kernel                 => 'linux',
          :monit_version          => '5',
        }
      end
      let(:params) do
        {
          :manage_firewall => true,
          :httpd           => true,
        }
      end

      it do
        should contain_firewall('2812 allow Monit inbound traffic').with({
          'action' => 'accept',
          'dport'  => '2812',
          'proto'  => 'tcp',
        })
      end
    end

    context 'when package_ensure is set to valid string <absent>' do
      let(:params) { { :package_ensure => 'absent' } }
      it { should contain_package('monit').with_ensure('absent') }
    end

    context 'when package_name is set to valid string <monit3>' do
      let(:params) { { :package_name => 'monit3' } }
      it { should contain_package('monit').with_name('monit3') }
    end

    context 'when service_enable is set to valid bool <false>' do
      let(:params) { { :service_enable => false } }
      it { should contain_service('monit').with_enable(false) }
    end

    context 'when service_ensure is set to valid string <stopped>' do
      let(:params) { { :service_ensure => 'stopped' } }
      it { should contain_service('monit').with_ensure('stopped') }
    end

    context 'when service_manage is set to valid bool <false>' do
      let(:params) { { :service_manage => false } }
      it { should_not contain_service('monit') }
      it { should_not contain_file('/etc/default/monit') }
    end

    context 'when service_name is set to valid string <stopped>' do
      let(:params) { { :service_name => 'monit3' } }
      it { should contain_service('monit').with_name('monit3') }
    end

    context 'when logfile is set to valid path </var/log/monit3.log>' do
      let(:params) { { :logfile => '/var/log/monit3.log' } }
      it { should contain_file('monit_config').with_content(%r{^set logfile /var/log/monit3.log$}) }
    end

    context 'when logfile is set to valid string <syslog>' do
      let(:params) { { :logfile => 'syslog' } }
      it { should contain_file('monit_config').with_content(/^set logfile syslog$/) }
    end

    context 'when mailserver is set to valid string <mailhost>' do
      let(:params) { { :mailserver => 'mailhost' } }
      it { should contain_file('monit_config').with_content(/^set mailserver mailhost$/) }
    end

    context 'when mailformat is set to valid hash' do
      let(:params) do
        {
          :mailformat => {
            'from'    => 'monit@test.local',
            'message' => 'Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION',
            'subject' => 'spectesting',
          }
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |set mail-format \{
        |    from: monit\@test.local
        |    message: Monit \$ACTION \$SERVICE at \$DATE on \$HOST: \$DESCRIPTION
        |    subject: spectesting
        |\}
      END
      it { should contain_file('monit_config').with_content(/#{Regexp.escape(content)}/) }
    end

    context 'when alert_emails is set to valid array' do
      let(:params) do
        {
          :alert_emails => [
            'spec@test.local',
            'tester@test.local',
          ]
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |set alert spec@test.local
        |set alert tester@test.local
      END
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when mmonit_address is set to valid string <monit3.test.local>' do
      let(:params) { { :mmonit_address => 'monit3.test.local' } }
      content = 'set mmonit http://monit:monit@monit3.test.local:8080/collector'
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when mmonit_without_credential is set to valid bool <true>' do
      let(:params) do
        {
          :mmonit_without_credential => true,
          :mmonit_address            => 'monit3.test.local',
        }
      end
      content = '   and register without credentials'
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when mmonit_* params are set to valid values' do
      let(:params) do
        {
          :mmonit_address  => 'monit242.test.local',
          :mmonit_port     => '8242',
          :mmonit_user     => 'monituser',
          :mmonit_password => 'Pa55w0rd',
        }
      end
      content = 'set mmonit http://monituser:Pa55w0rd@monit242.test.local:8242/collector'
      it { should contain_file('monit_config').with_content(/#{content}/) }
    end

    context 'when config_file is set to valid path </etc/monit3.conf>' do
      let(:params) { { :config_file => '/etc/monit3.conf' } }
      it { should contain_file('monit_config').with_path('/etc/monit3.conf') }
    end

    context 'when config_dir is set to valid path </etc/monit3/conf.d>' do
      let(:params) { { :config_dir => '/etc/monit3/conf.d' } }
      it { should contain_file('monit_config_dir').with_path('/etc/monit3/conf.d') }
    end

    context 'when config_dir_purge is set to valid bool <true>' do
      let(:params) { { :config_dir_purge => true } }
      it do
        should contain_file('monit_config_dir').with({
          'purge'   => true,
          'recurse' => true,
        })
      end
    end
  end

  describe 'failures' do
    let(:facts) do
      {
        :osfamily        => 'Debian',
        :lsbdistcodename => 'squeeze',
        :monit_version   => '5',
      }
    end

    [-1, 65_536].each do |value|
      context "when httpd_port is set to invalid value <#{value}>" do
        let(:params) do
          {
            :httpd          => true,
            :httpd_port     => value,
            :httpd_address  => 'otherhost',
            :httpd_user     => 'tester',
            :httpd_password => 'Passw0rd',
          }
        end
        it 'should fail' do
          expect do
            should contain_class('monit')
          end.to raise_error(Puppet::Error, /Expected #{value} to be (smaller|greater) or equal to (0|65535)/)
        end
      end
    end

    context 'when check_interval is set to invalid value <-1>' do
      let(:params) { { :check_interval => -1 } }

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /to be greater or equal to 0/)
      end
    end

    context 'when start_delay is set to invalid value <-1>' do
      let(:params) { { :start_delay => -1 } }

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /to be greater or equal to 0/)
      end
    end

    context 'when major release of EL is unsupported' do
      let :facts do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '4',
          :monit_version             => '5',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports EL 5, 6 and 7\. Detected operatingsystemmajrelease is <4>/)
      end
    end

    context 'when major release of Debian is unsupported' do
      let :facts do
        { :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '4',
          :lsbdistcodename           => 'etch',
          :monit_version             => '5',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports Debian 6 \(squeeze\) and 7 \(wheezy\) and Ubuntu 10\.04 \(lucid\), 12\.04 \(precise\) and 14\.04 \(trusty\)\. Detected lsbdistcodename is <etch>\./)
      end
    end

    context 'when major release of Ubuntu is unsupported' do
      let :facts do
        { :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '8',
          :lsbdistcodename           => 'hardy',
          :monit_version             => '5',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports Debian 6 \(squeeze\) and 7 \(wheezy\) and Ubuntu 10\.04 \(lucid\), 12\.04 \(precise\) and 14\.04 \(trusty\)\. Detected lsbdistcodename is <hardy>\./)
      end
    end

    context 'when osfamily is unsupported' do
      let :facts do
        { :osfamily                  => 'Unsupported',
          :operatingsystemmajrelease => '9',
          :monit_version             => '5',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports osfamilies Debian and RedHat\. Detected osfamily is <Unsupported>\./)
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '6.0',
        :operatingsystemmajrelease => '6',
        :lsbdistcodename           => 'squeeze',
        :monit_version             => '5',
      }
    end
    let(:validation_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'absolute_path' => {
        :name    => %w(config_file config_dir logfile),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }],
        :message => 'is not an absolute path',
      },
      'array' => {
        :name    => %w(alert_emails),
        :valid   => [%w(valid array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'is not an Array',
      },
      'bool_stringified' => {
        :name    => %w(httpd manage_firewall service_enable service_manage mmonit_without_credential config_dir_purge),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }, nil],
        :message => '(is not a boolean|Unknown type of boolean)',
      },
      'hash' => {
        :name    => %w(mailformat ),
        :valid   => [{ 'ha' => 'sh' }],
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
      },
      'integer_stringified' => {
        :name    => %w(check_interval httpd_port start_delay),
        :valid   => [242, '242'],
        :invalid => [2.42, 'invalid', %w(array), { 'ha' => 'sh ' }, true, false, nil],
        :message => 'Expected.*to be an Integer',
      },
      'string' => {
        :name    => %w(
          httpd_address httpd_user httpd_password package_ensure package_name service_name
          mailserver mmonit_address mmonit_port mmonit_user mmonit_password
        ),
        :valid   => ['present'],
        :invalid => [%w(array), { 'ha' => 'sh' }],
        :message => 'is not a string',
      },
      'service_ensure_string' => {
        :name    => %w(service_ensure),
        :valid   => ['running'],
        :invalid => [%w(array), { 'ha' => 'sh' }],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => valid, }) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect do
                should contain_class(subject)
              end.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
