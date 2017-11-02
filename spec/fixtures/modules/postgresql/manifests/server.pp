# This installs a PostgreSQL server. See README.md for more details.
class postgresql::server (
  $postgres_password          = undef,

  $package_name               = undef,
  $package_ensure             = undef,

  $plperl_package_name        = undef,
  $plpython_package_name      = undef,

  $service_ensure             = undef,
  $service_enable             = undef,
  $service_manage             = undef,
  $service_name               = undef,
  $service_restart_on_change  = undef,
  $service_provider           = undef,
  $service_reload             = undef,
  $service_status             = undef,
  $default_database           = undef,
  $default_connect_settings   = undef,
  $listen_addresses           = undef,
  $port                       = undef,
  $ip_mask_deny_postgres_user = undef,
  $ip_mask_allow_all_users    = undef,
  $ipv4acls                   = undef,
  $ipv6acls                   = undef,

  $initdb_path                = undef,
  $createdb_path              = undef,
  $psql_path                  = undef,
  $pg_hba_conf_path           = undef,
  $pg_ident_conf_path         = undef,
  $postgresql_conf_path       = undef,
  $recovery_conf_path         = undef,

  $datadir                    = undef,
  $xlogdir                    = undef,
  $logdir                     = undef,

  $log_line_prefix            = undef,

  $pg_hba_conf_defaults       = undef,

  $user                       = undef,
  $group                      = undef,

  $needs_initdb               = undef,

  $encoding                   = undef,
  $locale                     = undef,
  $data_checksums             = undef,
  $timezone                   = undef,

  $manage_pg_hba_conf         = undef,
  $manage_pg_ident_conf       = undef,
  $manage_recovery_conf       = undef,
  $module_workdir             = undef,
  #Deprecated
  $version                    = undef,
) inherits postgresql::params {
}

