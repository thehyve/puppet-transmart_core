class transmart_core::params(
    $user               = hiera('transmart_core::user', 'transmart'),
    $user_home          = hiera('transmart_core::user_home', undef),
    $version            = hiera('transmart_core::version', '17.1-SNAPSHOT'),
    $nexus_url          = hiera('transmart_core::nexus_url', 'https://repo.thehyve.nl'),
    $repository         = hiera('transmart_core::repository', 'snapshots'),

    $db_user            = hiera('transmart_core::db_user', ''),
    $db_password        = hiera('transmart_core::db_password', ''),
    $db_type            = hiera('transmart_core::db_type', 'postgresql'), # or 'oracle'
    $db_host            = hiera('transmart_core::db_host', 'localhost'),
    $db_port_spec       = hiera('transmart_core::db_port', ''),
    $db_name_spec       = hiera('transmart_core::db_name', undef),
    $biomart_user_password = hiera('transmart_core::biomart_user_password', 'biomart_user'),
    $tm_cz_user_password = hiera('transmart_core::tm_cz_user_password', 'tm_cz'),

    $memory             = hiera('transmart_core::memory', '2g'),
    $app_port           = hiera('transmart_core::app_port', '8080'),

    $transmart_url      = hiera('transmart_core::transmart_url', undef),
    $jobs_directory     = '/var/tmp/jobs',

    $saml_enabled       = hiera('transmart_core::saml_enabled', false),
    $saml_idp_meta_f    = '/etc/transmart-idp-metadata.xml',
    $saml_keystore_f    = '/etc/transmart-sp-keystore.jks',
) {
    # Set Nexus location
    $nexus_repository = "${nexus_url}/content/repositories/${repository}/"

    # Database settings
    if ($db_user == '') {
        fail('No database user specified. Please configure transmart_core::db_user')
    }
    if ($db_password == '') {
        fail('No database password specified. Please configure transmart_core::db_password')
    }
    case $db_type {
        'postgresql': {
            $postgresql_params = {
                version             => '9.4',
                manage_package_repo => true,
            }
            $tablespaces_dir = "/var/lib/pgsql/${postgresql_params[version]}/data/tablespaces"
            if $db_port_spec {
              $db_port = $db_port_spec
            } else {
              $db_port = 5432
            }
            if $db_name_spec {
                $db_name = $db_name_spec
            } else {
                $db_name = 'transmart'
            }
            $db_url = "jdbc:postgresql://${db_host}:${db_port}/${db_name}"
        }
        'oracle': {
            if $db_port_spec {
              $db_port = $db_port_spec
            } else {
              $db_port = 1521
            }
            if $db_name_spec {
                $db_name = $db_name_spec
            } else {
                $db_name = 'ORCL'
            }
            $db_url = "jdbc:oracle:thin:@${db_host}:${db_port}:${db_name}"
        }
        default: {
            fail("Unsupported database type: '${db_type}'. Options: postgresql, oracle.")
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

