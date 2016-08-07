require 'spec_helper'

describe 'monit::check' do
  let(:title) { 'test' }
  let(:facts) do
    {
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze',
      :monit_version   => '5',
    }
  end

  context 'with default values for parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('monit') }
    it do
      should contain_file('/etc/monit/conf.d/test').with({
        'ensure'  => 'present',
        'owner'   => 0,
        'group'   => 0,
        'mode'    => '0644',
        'source'  => nil,
        'content' => nil,
        'notify'  => 'Service[monit]',
        'require' => 'Package[monit]',
      })
    end
  end

  %w(absent present).each do |value|
    context "with ensure set to valid <#{value}>" do
      let(:params) do
        {
          :ensure => value,
        }
      end

      it do
        should contain_file('/etc/monit/conf.d/test').with({
          'ensure'  => value,
          'owner'   => 0,
          'group'   => 0,
          'mode'    => '0644',
          'source'  => nil,
          'content' => nil,
          'notify'  => 'Service[monit]',
          'require' => 'Package[monit]',
        })
      end
    end
  end

  context 'with content set to a valid value' do
    content = <<-END.gsub(/^\s+\|/, '')
      |check process ntpd with pidfile /var/run/ntpd.pid
      |start program = "/etc/init.d/ntpd start"
      |stop  program = "/etc/init.d/ntpd stop"
      |if failed host 127.0.0.1 port 123 type udp then alert
      |if 5 restarts within 5 cycles then timeout
    END
    let(:params) do
      {
        :content => content,
      }
    end

    it do
      should contain_file('/etc/monit/conf.d/test').with({
        'ensure'  => 'present',
        'owner'   => 0,
        'group'   => 0,
        'mode'    => '0644',
        'source'  => nil,
        'content' => content,
        'notify'  => 'Service[monit]',
        'require' => 'Package[monit]',
      })
    end
  end

  context 'with source set to a valid value' do
    let(:params) do
      {
        :source => 'puppet:///modules/monit/ntp',
      }
    end

    it do
      should contain_file('/etc/monit/conf.d/test').with({
        'ensure'  => 'present',
        'owner'   => 0,
        'group'   => 0,
        'mode'    => '0644',
        'source'  => 'puppet:///modules/monit/ntp',
        'content' => nil,
        'notify'  => 'Service[monit]',
        'require' => 'Package[monit]',
      })
    end
  end

  context 'with content and source set at the same time' do
    let(:params) do
      {
       :content => 'content',
       :source  => 'puppet:///modules/subject/test',
      }
    end
    it 'should fail' do
      expect do
        should contain_class(subject)
      end.to raise_error(Puppet::Error, /Parameters source and content are mutually exclusive/)
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :osfamily        => 'Debian',
        :lsbdistcodename => 'squeeze',
        :monit_version   => '5',
      }
    end
    let(:validation_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'regex_file_ensure' => {
        :name    => %w(ensure),
        :valid   => %w(present absent),
        :invalid => ['file', 'directory', 'link', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'must be \'present\' or \'absent\'',
      },
      'string' => {
        :name    => %w(content),
        :valid   => %w(string),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a string',
      },
      'string_file_source' => {
        :name    => %w(source),
        :valid   => %w(puppet:///modules/subject/test),
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
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
