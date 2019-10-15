# Copyright 2017 The Hyve.
class transmart_core::params(
    String $user                         = lookup('transmart_core::user', String, first, 'transmart'),
    Optional[String] $user_home          = lookup('transmart_core::user_home', Optional[String], first, undef),
    String $version                      = lookup('transmart_core::version', String, first, '17.2.4'),
    String $nexus_url                    = lookup('transmart_core::nexus_url', String, first, 'https://repo.thehyve.nl'),
    String $repository                   = lookup('transmart_core::repository', String, first, 'releases'),

    String $tsloader_user                = lookup('transmart_core::tsloader_user', String, first, 'tsloader'),
    Optional[String] $tsloader_user_home = lookup('transmart_core::tsloader_home', Optional[String], first, undef),

    String $db_user                      = lookup('transmart_core::db_user', String, first, ''),
    String $db_password                  = lookup('transmart_core::db_password', String, first, ''),
    Enum['postgresql','oracle'] $db_type = lookup('transmart_core::db_type', Enum['postgresql','oracle'], first, 'postgresql'),
    String $db_host                      = lookup('transmart_core::db_host', String, first, 'localhost'),
    Optional[Integer] $db_port_spec      = lookup('transmart_core::db_port', Optional[Integer], first, undef),
    Optional[String] $db_name_spec       = lookup('transmart_core::db_name', Optional[String], first, undef),

    String $biomart_user_password        = lookup('transmart_core::biomart_user_password', String, first, 'biomart_user'),
    String $tm_cz_user_password          = lookup('transmart_core::tm_cz_user_password', String, first, 'tm_cz'),

    String $memory                       = lookup('transmart_core::memory', String, first, '2g'),
    Variant[String,Integer[1,65535]] $app_port
        = lookup('transmart_core::app_port', Variant[String,Integer[1,65535]], first, '8080'),
    Boolean $disable_server              = lookup('transmart_core::disable_server', Boolean, first, false),

    Optional[String] $transmart_url      = lookup('transmart_core::transmart_url', Optional[String], first, undef),
    String $jobs_directory               = '/var/tmp/jobs',

    Boolean $cors_enabled                = lookup('transmart_core::cors_enabled', Boolean, first, true),

    Boolean $saml_enabled                = lookup('transmart_core::saml_enabled', Boolean, first, false),
    Optional[String] $saml_idp_meta_f    = '/etc/transmart-idp-metadata.xml',
    Optional[String] $saml_keystore_f    = '/etc/transmart-sp-keystore.jks',

    Hash[String, Array[String]] $clients = lookup('transmart_core::clients', Hash, first, {'glowingbear-js' => []}),

    Enum['api-server', 'app-server'] $server_type
        = lookup('transmart_core::server_type', Enum['api-server', 'app-server'], first, 'app-server'),

    Boolean $notifications_enabled       = lookup('transmart_core::notifications_enabled', Boolean, first, false),
    Integer $notifications_sets          = lookup('transmart_core::notifications_sets', Integer, first, 20),
    Integer[0,23] $notifications_trigger_hour = lookup('transmart_core::notifications_trigger_hour', Integer[0,23], first, 0),
    Integer[0,59] $notifications_trigger_minute = lookup('transmart_core::notifications_trigger_minute', Integer[0,59], first, 0),

    Optional[Integer[1]] $number_of_workers  = lookup('transmart_core::number_of_workers', Optional[Integer[1]], first, undef),
    Integer[1] $max_connections              = lookup('transmart_core::max_connections', Integer[1], first, 50),

    Optional[String] $keycloak_realm         = lookup('transmart_core::keycloak_realm', Optional[String], first, undef),
    Optional[String] $keycloak_server_url    = lookup('transmart_core::keycloak_server_url', Optional[String], first, undef),
    Optional[String] $keycloak_client_id     = lookup('transmart_core::keycloak_client_id', Optional[String], first, undef),
    Optional[String] $keycloak_offline_token = lookup('transmart_core::keycloak_offline_token', Optional[String], first, undef),
    Boolean $keycloak_disable_trust_manager  = lookup('transmart_core::keycloak_disable_trust_manager', Boolean, first, false),
    Integer[0] $counts_threshold = lookup('transmart_core::counts_threshold', Integer[0], first, 0),
    Optional[String] $sender_email = lookup('transmart_core::sender_email', Optional[String], first, undef),

    String $custom_config                = lookup('transmart_core::custom_config', String, first, ''),

    # to activate liquibase
    Boolean $liquibase_on = lookup('transmart_core::liquibase_on', Boolean, first, false),
    Boolean $install_pg_bitcount = lookup('transmart_core::install_pg_bitcount', Boolean, first, false),

    # Log to database by default
    Boolean $log2database = lookup('transmart_core::log2database', Boolean, first, true),
) {
    # Database settings
    case $db_type {
        'postgresql': {
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

    if $liquibase_on and $log2database {
        fail('When using Liquibase for database updates (liquibase_on), log2database should be false.')
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

