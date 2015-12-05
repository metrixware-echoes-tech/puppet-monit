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
        if v[:osfamily] == 'Solaris'
          let :facts do
            { :osfamily      => v[:osfamily],
              :kernelrelease => v[:release],
            }
          end
        else
          let :facts do
            { :lsbdistcodename           => v[:lsbdistcodename],
              :osfamily                  => v[:osfamily],
              :operatingsystemrelease    => v[:release],
              :operatingsystemmajrelease => v[:majrelease],
            }
          end
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

  describe 'with an unsupported' do
    context 'version of EL' do
      let :facts do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '4',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports EL 5, 6 and 7\. Detected operatingsystemmajrelease is <4>/)
      end
    end

    context 'version of Debian' do
      let :facts do
        { :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '4',
          :lsbdistcodename           => 'etch',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports Debian 6 \(squeeze\) and 7 \(wheezy\) and Ubuntu 10\.04 \(lucid\), 12\.04 \(precise\) and 14\.04 \(trusty\)\. Detected lsbdistcodename is <etch>\./)
      end
    end

    context 'version of Ubuntu' do
      let :facts do
        { :osfamily                  => 'Debian',
          :operatingsystemmajrelease => '8',
          :lsbdistcodename           => 'hardy',
        }
      end

      it 'should fail' do
        expect do
          should contain_class('monit')
        end.to raise_error(Puppet::Error, /monit supports Debian 6 \(squeeze\) and 7 \(wheezy\) and Ubuntu 10\.04 \(lucid\), 12\.04 \(precise\) and 14\.04 \(trusty\)\. Detected lsbdistcodename is <hardy>\./)
      end
    end

    context 'osfamily' do
      let :facts do
        { :osfamily                  => 'Unsupported',
          :operatingsystemmajrelease => '9',
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
      'bool' => {
        :name    => %w(httpd manage_firewall service_enable service_manage mmonit_without_credential),
        :valid   => [true, false],
        :invalid => ['true', 'false', 'invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }, nil],
        :message => 'is not a boolean',
      },
      'bool_stringified' => {
        :name    => %w(config_dir_purge),
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
