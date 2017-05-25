class transmart_core::data inherits transmart_core::params {
    include ::transmart_core

    $tsloader_user = $::transmart_core::params::tsloader_user
    $tsloader_home = $::transmart_core::params::tsloader_home
    $tsdata_tar_file = $::transmart_core::params::tsdata_tar_file
    $tsdata_dir = $::transmart_core::params::tsdata_dir

    File {
        owner   => $tsloader_user,
        group   => $tsloader_user,
        require => User[$tsloader_user],
    }

    $db_user = $::transmart_core::params::db_user
    $db_password = $::transmart_core::params::db_password

    if ($db_user == '') {
        fail('No database user specified. Please configure transmart_core::db_user')
    }
    if ($db_password == '') {
        fail('No database password specified. Please configure transmart_core::db_password')
    }

    # Download and untar transmart-data
    archive::nexus { $tsdata_tar_file:
        user         => $tsloader_user,
        url          => $::transmart_core::params::nexus_url,
        gav          => "org.transmartproject:transmart-data:${::transmart_core::params::version}",
        repository   => $::transmart_core::params::repository,
        packaging    => 'tar',
        extract      => true,
        extract_path => $tsloader_home,
        creates      => $tsdata_dir,
        cleanup      => true,
    }
    # Create database configuration file for transmart-data
    -> file { "${tsdata_dir}/vars":
        ensure  => file,
        content => template('transmart_core/config/tsdata-vars.erb'),
        mode    => '0400',
    }

}

