require 'spec_helper'
describe 'monit' do

  context 'with defaults for all parameters' do
    it { should contain_class('monit') }
  end
end
