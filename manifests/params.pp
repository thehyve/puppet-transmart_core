class transmart_core::params(
    $user               = hiera('transmart_core::user', 'transmart'),
    $version            = hiera('transmart_core::version', '17.1-SNAPSHOT'),
    $nexus_repository   = hiera('transmart_core::nexus_repository', 'https://repo.thehyve.nl'),
    $db_user            = hiera('transmart_core::db_user', ''),
    $db_password        = hiera('transmart_core::db_password', ''),
    $db_url             = hiera('transmart_core::db_url', ''),
    $db_type            = hiera('transmart_core::db_type', 'postgresql'), # or 'oracle'
    $dbport_spec        = hiera('transmart_core::db_url', ''),

    $dbhost             = '', # vars, needs to change if db is in another machine
    $databasename       = 'transmart', # vars

    $user_home          = undef,
) {
    if $db_type == 'postgresql' {
        $postgresql_params  = {
            version             => '9.4',
            manage_package_repo => true,
        }
        $tablespaces_dir = "/var/lib/pgsql/${postgresql_params[$version]}/data/tablespaces"
        if $dbport_spec {
          $dbport = $dbport_spec
        } else {
          $dbport = 5432
        }
    } else {
        if $dbport_spec {
          $dbport = $dbport_spec
        } else {
          $dbport = 1521
        }
    }

    # Set home directory
    if $user_home == undef {
        $tsuser_home = "/home/${user}"
    } else {
        $tsuser_home = $user_home
    }

    $tsdata_tar_file = "${tsuser_home}/transmart-data-${version}.tar"

    # Set transmart-data directory
    $tsdata_dir = "${tsuser_home}/transmart-data-${version}"

}

