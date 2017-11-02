# source.pp
# add an apt source
define apt::source(
    $location          = undef,
    $comment           = $name,
    $ensure            = present,
    $release           = undef,
    $repos             = 'main',
    $include           = {},
    $key               = undef,
    $pin               = undef,
    $architecture      = undef,
    $allow_unsigned    = false,
    $include_src       = undef,
    $include_deb       = undef,
    $required_packages = undef,
    $key_server        = undef,
    $key_content       = undef,
    $key_source        = undef,
    $trusted_source    = undef,
    $notify_update     = true,
) {
}

