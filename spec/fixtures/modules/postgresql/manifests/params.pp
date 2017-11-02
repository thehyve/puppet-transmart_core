class postgresql::params inherits postgresql::globals {
  $version                    = undef
  $postgis_version            = undef
  $listen_addresses           = 'localhost'
  $port                       = 5432
  $ip_mask_deny_postgres_user = '0.0.0.0/0'
  $ip_mask_allow_all_users    = '127.0.0.1/32'
  $ipv4acls                   = []
  $ipv6acls                   = []
  $encoding                   = undef
  $locale                     = undef
  $service_ensure             = 'running'
  $service_enable             = true
  $service_manage             = true
  $service_restart_on_change  = true
  $service_provider           = undef
  $manage_pg_hba_conf         = undef
  $manage_pg_ident_conf       = undef
  $manage_recovery_conf       = undef
  $package_ensure             = 'present'
  
  $datadir = undef
}
