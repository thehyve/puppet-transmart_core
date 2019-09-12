require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = './spec/fixtures/hiera.yaml'

  c.before(:each) do
    Puppet::Parser::Functions.newfunction(:postgresql_password, :type => :rvalue, :doc => <<-EOS
        Returns the postgresql password hash from the clear text username / password.
    EOS
    ) do |args|

      raise(Puppet::ParseError, "postgresql_password(): Wrong number of arguments " +
          "given (#{args.size} for 2)") if args.size != 2

      username = args[0]
      password = args[1]

      'md5' + password.to_s + username.to_s
    end
  end
end

