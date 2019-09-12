require 'spec_helper'
describe 'transmart_core::liquibase' do
  on_supported_os.each do |os, facts|
    context "with api-server server type and database update on startup on #{os}" do
      let(:facts) { facts }
      let(:node) { 'db-update.example.com' }
      it { is_expected.to create_class('transmart_core::liquibase') }
    end
  end
end
