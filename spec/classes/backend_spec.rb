require 'spec_helper'
describe 'transmart_core::backend' do
  on_supported_os.each do |os, facts|
    context "with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test2.example.com' }
      it { is_expected.to create_class('transmart_core::backend') }
    end
    context "with clients and redirect URIs set on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      it { is_expected.to create_class('transmart_core::backend') }
    end
    context "with api-server server type without oidc configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api2.example.com' }
      it { should compile.and_raise_error(/No realm specified/) }
    end
    context "with api-server server type and valid oidc configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api1.example.com' }
      it { is_expected.to create_class('transmart_core::backend') }
    end
    context "with api-server server type and database update on startup on #{os}" do
      let(:facts) { facts }
      let(:node) { 'db-update.example.com' }
      it { is_expected.to create_class('transmart_core::backend') }
    end
  end
end
