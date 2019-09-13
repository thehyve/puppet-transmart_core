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

  if ($::transmart_core::params::install_pg_bitcount) {
    $postgresql_version = $::postgresql::globals::version
    $pg_bitcount_package = "postgresql-${$postgresql_version}-pg-bitcount"
    $pg_bitcount_package_version = '0.0.3-1'
    $pg_bitcount_deb = "postgresql-${$postgresql_version}-pg-bitcount_${pg_bitcount_package_version}_amd64.deb"

    archive { "/opt/${pg_bitcount_deb}":
      ensure  => present,
      source  => "https://github.com/thehyve/pg_bitcount/releases/download/${pg_bitcount_package_version}/${pg_bitcount_deb}",
      creates => "/opt/${pg_bitcount_deb}",
      cleanup => false,
      user    => root,
    }
    -> package { $pg_bitcount_package:
      ensure   => latest,
      provider => dpkg,
      source   => "/opt/${pg_bitcount_deb}"
    }
  }

}
