# Copyright 2017 The Hyve.
class transmart_core::database inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    if $::transmart_core::params::db_type != 'postgresql' {
        fail("Class ::transmart_core::database not available for db_type '${::transmart_core::params::db_type}'")
    }

    $tablespace_prefix = "/var/lib/postgresql/${::transmart_core::params::postgresql_params[version]}/main/tablespaces"
    
    class { '::postgresql::globals':
        manage_package_repo => $::transmart_core::params::postgresql_params[manage_package_repo],
        version             => $::transmart_core::params::postgresql_params[version],
    }
    -> class { '::postgresql::server':
    }
    # Create database superuser
    -> postgresql::server::role { $::transmart_core::params::db_user:
        password_hash => $::transmart_core::params::db_password,
        superuser     => true,
    }

    # Create TranSMART tablespace directories
    file { [$tablespace_prefix, "${tablespace_prefix}/transmart", "${tablespace_prefix}/indx"]:
        ensure  => directory,
        owner   => 'postgres',
        mode    => '0755',
        require => Class['::postgresql::server'],
    }

}

