require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = './spec/fixtures/hiera.yaml'

  c.before(:each) do
    # @summary This function returns the postgresql password hash from the clear text username / password
    Puppet::Functions.create_function(:'postgresql::postgresql_password') do
      # @param username
      #   The clear text `username`
      # @param password
      #   The clear text `password`
      #
      # @return [String]
      #   The postgresql password hash from the clear text username / password.
      dispatch :default_impl do
        param 'Variant[String[1],Integer]', :username
        param 'Variant[String[1],Integer]', :password
      end

      def default_impl(username, password)
        'md5' + password.to_s + username.to_s
      end
    end
  end
end
