class transmart_core::database inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    if $::transmart_core::params::db_type != 'postgresql' {
        fail("Class ::transmart_core::database not available for db_type '${::transmart_core::params::db_type}'")
    }

    class { '::postgresql::globals':
        manage_package_repo => $::transmart_core::params::postgresql_params::manage_package_repo,
        version             => $::transmart_core::params::postgresql_params::version,
    }
    -> class { '::postgresql::server':
    }
    # Create database
    -> postgresql::server::db { $::transmart_core::params::db_name:
        user     => $::transmart_core::params::db_user,
        password => $::transmart_core::params::db_password,
    }

}

