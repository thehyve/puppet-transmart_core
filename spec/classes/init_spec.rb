require 'spec_helper'
describe 'transmart_core' do
  on_supported_os.each do |os, facts|
    context "with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test2.example.com' }
      it { is_expected.to create_class('transmart_core') }
    end
    context "with database credentials set on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      it { is_expected.to create_class('transmart_core') }
    end
  end
end
