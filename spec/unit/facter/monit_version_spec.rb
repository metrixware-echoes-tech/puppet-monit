require 'spec_helper'
require 'facter/monit_version'

describe 'Facter::Util::MonitVersion (monit_version)' do
  context 'with monit v5.14 installed' do
    let(:monit_version) do
      "This is Monit version 5.14\nCopyright (C) 2001-2015 Tildeslash Ltd. All Rights Reserved."
    end
    it 'should return 5.14' do
      Facter::Util::Resolution.expects(:exec).with('monit -V 2>&1').returns(monit_version)
      expect(Facter::Util::MonitVersion.get_monit_version).to eq('5.14')
    end
  end
  context 'with monit not installed' do
    it 'should be nil' do
      Facter::Util::Resolution.expects(:exec).with('monit -V 2>&1').returns(nil)
      expect(Facter::Util::MonitVersion.get_monit_version).to be_nil
    end
  end
end
