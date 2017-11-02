# Define for granting permissions to roles. See README.md for more details.
define postgresql::server::grant (
  $role,
  $db,
  $privilege        = undef,
  $object_type      = 'database',
  $object_name      = undef,
  $psql_db          = undef,
  $psql_user        = undef,
  $port             = undef,
  $onlyif_exists    = false,
  $connect_settings = undef,
) {
}
