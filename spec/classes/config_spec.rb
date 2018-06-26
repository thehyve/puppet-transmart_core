require 'spec_helper'
describe 'transmart_core::config' do
  on_supported_os.each do |os, facts|
    context "with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test2.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/.grails/transmartConfig/application.groovy')}
    end
    context "with clients and redirect URIs set on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/.grails/transmartConfig/application.groovy')}
    end
    context "with api-server server type on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api2.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml')}
    end
    context "with api-server server type and valid oidc configuration on #{os}" do
      let(:facts) { facts }
      let(:node) { 'api1.example.com' }
      it { is_expected.to create_class('transmart_core::config') }
      it { is_expected.to contain_file('/home/transmart/transmart-api-server.config.yml')}
    end
  end
end
