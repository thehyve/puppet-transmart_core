require 'spec_helper'

describe 'api1.example.com' do
  on_supported_os.each do |os, facts|
    context "transmart_core with transmart-api-server configured on #{os}" do
      let(:facts) { facts }
      it { is_expected.to create_class('transmart_core') }
    end
  end
end
