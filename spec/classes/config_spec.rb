require 'spec_helper'
describe 'transmart_core::config' do
  on_supported_os.each do |os, facts|
    context "with default values on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api2.example.com' }
      it { should compile.and_raise_error(/No realm specified/) }
    end
    context "with valid oidc configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api1.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml').with_content(/auth-server-url: https:\/\/oidc.example.com/) }
    end
    context "with api-server server type and database update on startup on #{os}" do
      let(:facts) { facts }
      let(:node) { 'db-update.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml').with_content(/updateOnStart: true/)}
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml').with_content(/writeLogToDatabase: false/)}
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml').with_content(/verify-token-audience: true/)}
    end
  end
end
