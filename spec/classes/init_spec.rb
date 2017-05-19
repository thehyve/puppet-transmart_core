require 'spec_helper'
describe 'transmart_core' do
  context 'with default values for all parameters' do
    it { should compile.and_raise_error(/No database user/) }
  end
end
