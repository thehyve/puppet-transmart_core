# Copyright 2017 The Hyve.
class transmart_core::database inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    if $::transmart_core::params::db_type != 'postgresql' {
        fail("Class ::transmart_core::database not available for db_type '${::transmart_core::params::db_type}'")
    }

    class { '::postgresql::globals':
        manage_package_repo => true,
    }
    -> class { '::postgresql::server':
    }
    # Create database superuser
    -> postgresql::server::role { $::transmart_core::params::db_user:
        password_hash => $::transmart_core::params::db_password,
        superuser     => true,
    }

    # Create TranSMART tablespaces
    postgresql::server::tablespace { 'transmart':
        require => Class['::postgresql::server'],
    }
    postgresql::server::tablespace { 'indx':
        require => Class['::postgresql::server'],
    }

}

