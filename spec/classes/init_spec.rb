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
        :osfamily => 'RedHat'
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

#  context "With a package name specified" do
#    let :params do
#      {
#        :package_name => 'abcd'
#      }
#    end
#
#    it {
#      should contain_package('monit').with( { 'name' => 'abcd' } )
#      should contain_service('monit').with( { 'name' => 'abcd' } )
#    }
#  end

end
