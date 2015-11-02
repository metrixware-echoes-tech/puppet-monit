require 'spec_helper'
describe 'monit', :type => 'class' do

  context "On a Debian OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it {
      should contain_package('monit')
      should contain_service('monit')
    }
  end

  context "On a RedHat OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '6',
      }
    end

    it {
      should contain_package('monit')
      should contain_service('monit')
    }
  end

  context "On an unknown OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
end
