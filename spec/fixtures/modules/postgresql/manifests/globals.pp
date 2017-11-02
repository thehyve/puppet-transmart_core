# Class for setting cross-class global overrides. See README.md for more
# details.
class postgresql::globals (
  $client_package_name      = undef,
  $server_package_name      = undef,
  $contrib_package_name     = undef,
  $devel_package_name       = undef,
  $java_package_name        = undef,
  $docs_package_name        = undef,
  $perl_package_name        = undef,
  $plperl_package_name      = undef,
  $plpython_package_name    = undef,
  $python_package_name      = undef,
  $postgis_package_name     = undef,

  $service_name             = undef,
  $service_provider         = undef,
  $service_status           = undef,
  $default_database         = undef,

  $validcon_script_path     = undef,

  $initdb_path              = undef,
  $createdb_path            = undef,
  $psql_path                = undef,
  $pg_hba_conf_path         = undef,
  $pg_ident_conf_path       = undef,
  $postgresql_conf_path     = undef,
  $recovery_conf_path       = undef,
  $default_connect_settings = undef,

  $pg_hba_conf_defaults     = undef,

  $datadir                  = undef,
  $confdir                  = undef,
  $bindir                   = undef,
  $xlogdir                  = undef,
  $logdir                   = undef,

  $user                     = undef,
  $group                    = undef,

  $version                  = undef,
  $postgis_version          = undef,
  $repo_proxy               = undef,

  $needs_initdb             = undef,

  $encoding                 = undef,
  $locale                   = undef,

  $manage_pg_hba_conf       = undef,
  $manage_pg_ident_conf     = undef,
  $manage_recovery_conf     = undef,

  $manage_package_repo      = undef,
) {
}

