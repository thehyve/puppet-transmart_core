# Copyright 2017 The Hyve.
class transmart_core::params(
    String[1] $user = 'transmart',
    String[1] $version = '17.1-RC4',
    String[1] $nexus_url = 'https://repo.thehyve.nl',
    String[1] $repository = 'latest',

    String[1] $tsloader_user = 'tsloader',

    String $db_user = 'transmart_test',
    #String $db_user,
    String $db_password = 'thehyve',
    String[1] $db_type = 'postgresql_test',
    String[1] $db_host = 'localhost', 
    String[1] $db_name_spec = 'postgres',
    String[1] $db_port_spec = '5432',

    String[1] $biomart_user_password = 'biomart_user',
    String[1] $tm_cz_user_password = 'tm_cz',

    String[2] $memory = '2g',
    Integer $app_port = '8080',

    Optional[String[1]] $transmart_url = undef,

    Boolean $saml_enabled = false,
   
    Optional[String[1]] $user_home          =  undef,
    $jobs_directory     = '/var/tmp/jobs',
 
    String[1] $saml_idp_meta_f    = '/etc/transmart-idp-metadata.xml',
    Optional[String[1]] $tsloader_user_home = undef,
    String[1] $saml_keystore_f    = '/etc/transmart-sp-keystore.jks',
) {
    # Set Nexus location
    $nexus_repository = "${nexus_url}/content/repositories/${repository}/"

    # Database settings
    case $db_type {
        'postgresql': {
            $postgresql_params = {
                version             => '9.5',
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

    # Set transmart user home directory
    if $user_home == undef {
        $tsuser_home = "/home/${user}"
    } else {
        $tsuser_home = $user_home
    }

    # Set transmart loader user home directory
    if $tsloader_user_home == undef {
        $tsloader_home = "/home/${tsloader_user}"
    } else {
        $tsloader_home = $tsloader_user_home
    }

    $tsdata_tar_file = "${tsloader_home}/transmart-data-${version}.tar"

    # Set transmart-data directory
    $tsdata_dir = "${tsloader_home}/transmart-data-${version}"
}

