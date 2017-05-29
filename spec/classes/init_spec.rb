require 'spec_helper'
describe 'transmart_core' do
  context 'with default values for all parameters' do
    let(:node) { 'test2.example.com' }
    it { is_expected.to create_class('transmart_core') }
  end
  context 'with database credentials set' do
    let(:node) { 'test.example.com' }
    it { is_expected.to create_class('transmart_core') }
  end
end
