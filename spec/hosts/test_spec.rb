require 'spec_helper'

describe 'test.example.com' do
  context 'transmart_core with database credentials set' do
    it { is_expected.to create_class('transmart_core') }
  end
end
