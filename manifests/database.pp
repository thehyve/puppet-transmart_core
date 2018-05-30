# Copyright 2017 The Hyve.
class transmart_core::database inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    $db_type = $::transmart_core::params::db_type
    $db_user = $::transmart_core::params::db_user
    $db_password = $::transmart_core::params::db_password
    $tsuser = $::transmart_core::params::user

    if $db_type != 'postgresql' {
        fail("Class ::transmart_core::database not available for db_type '${db_type}'")
    }
    if ($db_user == '') {
        fail('No database user specified. Please configure transmart_core::db_user')
    }
    if ($db_password == '') {
        fail('No database password specified. Please configure transmart_core::db_password')
    }

    class { '::postgresql::server':
    }
    # Create database superuser
    -> postgresql::server::role { $db_user:
        password_hash => $db_password,
        superuser     => true,
    }

    $tablespaces_root = "${::postgresql::params::datadir}/../tablespaces/"

    File {
        owner   => $::postgresql::params::user,
        group   => $::postgresql::params::user,
    }
    file { $tablespaces_root:
        ensure  => directory,
        require => File[$::postgresql::params::datadir],
    }

    # Create TranSMART tablespaces
    postgresql::server::tablespace { 'transmart':
        location => "${tablespaces_root}transmart",
        require  => [Class['::postgresql::server'], File[$tablespaces_root]],
    }
    postgresql::server::tablespace { 'indx':
        location => "${tablespaces_root}indx",
        require  => [Class['::postgresql::server'], File[$tablespaces_root]],
    }

}

