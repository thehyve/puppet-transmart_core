require 'spec_helper'

describe 'test.example.com' do
  on_supported_os.each do |os, facts|
    context "transmart_core with database credentials set on #{os}" do
      let(:facts) { facts }
      it { is_expected.to create_class('transmart_core') }
    end
  end
end

describe 'api1.example.com' do
  on_supported_os.each do |os, facts|
    context "transmart_core with transmart-api-server configured on #{os}" do
      let(:facts) { facts }
      it { is_expected.to create_class('transmart_core') }
    end
  end
end
