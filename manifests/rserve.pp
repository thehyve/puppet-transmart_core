# Copyright 2017 The Hyve.
class transmart_core::rserve inherits transmart_core::params {
    require ::transmart_core
    require ::transmart_core::thehyve_repositories

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $rserve_script = "${home}/rserve"

    User[$user]
    -> package { 'transmart-r':
        ensure => 'latest',
        notify => Service['transmart-rserve'],
    }
    -> file { $rserve_script:
        ensure => file,
        owner  => $user,
        mode   => '0755',
        source => 'puppet:///modules/transmart_core/rserve',
    }
    -> file { '/etc/systemd/system/transmart-rserve.service':
        ensure  => file,
        mode    => '0644',
        content => template('transmart_core/service/transmart-rserve.service.erb'),
    }
    ~> service { 'transmart-rserve':
        ensure => running,
        enable => true,
    }

    # Package required for the R scripts
    package { 'libpng12': }

}

