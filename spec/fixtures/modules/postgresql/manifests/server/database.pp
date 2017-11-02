# Define for creating a database. See README.md for more details.
define postgresql::server::database(
  $comment          = undef,
  $dbname           = $title,
  $owner            = undef,
  $tablespace       = undef,
  $template         = 'template0',
  $encoding         = undef,
  $locale           = undef,
  $istemplate       = false,
  $connect_settings = undef,
) {
}
