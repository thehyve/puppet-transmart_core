# Copyright 2017 The Hyve.
class transmart_core::rserve inherits transmart_core::params {
    require ::transmart_core

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $rserve_script = "${home}/rserve"

    case $::osfamily {
        'redhat': {
            $create_rserve_service = true
            $libpng_pkg = 'libpng12'
        }
        'debian': {
            $create_rserve_service = false
            $libpng_pkg = 'libpng-dev'
        }
        default: {
            $create_rserve_service = false
            $libpng_pkg = 'libpng-dev'
        }
    }

    # Package required for the R scripts
    package { $libpng_pkg: }

    package { 'transmart-r':
        ensure => 'latest',
    }

    if $create_rserve_service {
        file { $rserve_script:
            ensure  => file,
            owner   => $user,
            mode    => '0755',
            source  => 'puppet:///modules/transmart_core/rserve',
            require => User[$user],
        }
        -> file { '/etc/systemd/system/transmart-rserve.service':
            ensure  => file,
            mode    => '0644',
            content => template('transmart_core/service/transmart-rserve.service.erb'),
        }
        ~> service { 'transmart-rserve':
            ensure   => running,
            provider => 'systemd',
            enable   => true,
        }
    }

}

