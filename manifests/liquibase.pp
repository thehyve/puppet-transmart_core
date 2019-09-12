# Copyright 2019 The Hyve.
class transmart_core::liquibase inherits transmart_core::params {
  include ::transmart_core
  include ::transmart_core::config

  $db_type = $::transmart_core::params::db_type
  $db_name = $::transmart_core::params::db_name
  $biomart_user_password = $::transmart_core::params::biomart_user_password

  if $db_type != 'postgresql' {
    fail("Class ::transmart_core::liquibase not available for db_type '${db_type}'")
  }
  if ($biomart_user_password == '') {
    fail('No biomart_user database password specified. Please configure transmart_core::biomart_user_password')
  }

  class { '::postgresql::server':
  }
  # Create database superuser
  -> postgresql::server::role { 'biomart_user':
    password_hash => postgresql_password('biomart_user', $biomart_user_password),
    superuser     => true,
    login         => true,
  }

  # Create TranSMART databases
  postgresql::server::database { $db_name: }

  # Database grants
  postgresql::server::database_grant { "grant all on ${db_name} to biomart_user":
    db        => $db_name,
    privilege => 'ALL',
    role      => 'biomart_user',
    }

}

