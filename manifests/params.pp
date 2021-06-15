# Copyright 2017 The Hyve.
class transmart_core::params(
    String $user                         = lookup('transmart_core::user', String, first, 'transmart'),
    Optional[String] $user_home          = lookup('transmart_core::user_home', Optional[String], first, undef),
    String $version                      = lookup('transmart_core::version', String, first, '17.2.4'),
    String $nexus_url                    = lookup('transmart_core::nexus_url', String, first, 'https://repo.thehyve.nl'),
    String $repository                   = lookup('transmart_core::repository', String, first, 'releases'),

    String $db_user                      = lookup('transmart_core::db_user', String, first, ''),
    String $db_password                  = lookup('transmart_core::db_password', String, first, ''),
    Enum['postgresql'] $db_type          = lookup('transmart_core::db_type', Enum['postgresql'], first, 'postgresql'),
    String $db_host                      = lookup('transmart_core::db_host', String, first, 'localhost'),
    Optional[Integer] $db_port_spec      = lookup('transmart_core::db_port', Optional[Integer], first, undef),
    Optional[String] $db_name_spec       = lookup('transmart_core::db_name', Optional[String], first, undef),

    String $biomart_user_password        = lookup('transmart_core::biomart_user_password', String, first, 'biomart_user'),

    String $memory                       = lookup('transmart_core::memory', String, first, '2g'),
    Variant[String,Integer[1,65535]] $app_port
        = lookup('transmart_core::app_port', Variant[String,Integer[1,65535]], first, '8080'),
    Boolean $disable_server              = lookup('transmart_core::disable_server', Boolean, first, false),

    Enum['api-server'] $server_type      = lookup('transmart_core::server_type', Enum['api-server'], first, 'api-server'),

    Optional[Integer[1]] $number_of_workers  = lookup('transmart_core::number_of_workers', Optional[Integer[1]], first, undef),
    Integer[1] $max_connections              = lookup('transmart_core::max_connections', Integer[1], first, 50),

    Optional[String] $keycloak_realm         = lookup('transmart_core::keycloak_realm', Optional[String], first, undef),
    Optional[String] $keycloak_server_url    = lookup('transmart_core::keycloak_server_url', Optional[String], first, undef),
    Optional[String] $keycloak_client_id     = lookup('transmart_core::keycloak_client_id', Optional[String], first, undef),

    # to activate liquibase
    Boolean $liquibase_on = lookup('transmart_core::liquibase_on', Boolean, first, false),
    Boolean $install_pg_bitcount = lookup('transmart_core::install_pg_bitcount', Boolean, first, false),
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
        default: {
            fail("Unsupported database type: '${db_type}'. Options: postgresql.")
        }
    }

    # Set transmart user home directory
    if $user_home == undef {
        $tsuser_home = "/home/${user}"
    } else {
        $tsuser_home = $user_home
    }
}

