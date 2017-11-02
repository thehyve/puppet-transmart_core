# == Class: apt
#
# Manage APT (Advanced Packaging Tool)
#
class apt (
    $confs    = {},
    $update   = {},
    $purge    = {},
    $proxy    = {},
    $sources  = {},
    $keys     = {},
    $ppas     = {},
    $pins     = {},
    $settings = {},
) inherits ::apt::params {
    include ::apt::update
}

