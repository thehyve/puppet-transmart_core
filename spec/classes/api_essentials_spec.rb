require 'spec_helper'
describe 'transmart_core::api_essentials' do
  on_supported_os.each do |os, facts|
    context "with default configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api2.example.com' }
      it { should compile.and_raise_error(/No realm specified/) }
    end
    context "with valid oidc configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api1.example.com' }
      it { is_expected.to create_class('transmart_core') }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to create_class('transmart_core::backend') }
    end
    context "with database update on startup on #{os}" do
      let(:facts) { facts }
      let(:node) { 'db-update.example.com' }
      it { is_expected.to create_class('transmart_core') }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to create_class('transmart_core::backend') }
    end
  end
end
