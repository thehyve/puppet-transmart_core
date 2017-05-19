class transmart_core::backend inherits transmart_core::params {

    $home = $::transmart_core::params::tsuser_home
    $application_war_file = "${home}/transmart-app.war"
    $start_script = "${home}/start"
    $logs_dir = "${home}/logs"

    # Download the application war
    maven { $application_war_file:
        ensure  => latest,
        user    => $user,
        id      => "org.transmartproject:transmartApp:${version}:war",
        repos   => 'https://repo.thehyve.nl/content/repositories/snapshots/',
        require => [ File[$home], Class['maven::maven'] ],
    }
    file { $logs_dir:
        ensure => directory,
        owner  => $user,
        mode   => '0700',
    }
    file { $start_script:
        ensure  => file,
        owner   => $user,
        mode    => '0744',
        content => template('transmart_core/start.erb'),
        notify  => Service['transmart-app'],
    }
    -> file { '/etc/systemd/system/transmart-app.service':
        ensure  => file,
        mode    => '0644',
        content => template('transmart_core/transmart-app.service.erb'),
        notify  => Service['transmart-app'],
    }
    # Start the application service
    -> service { 'transmart-app':
        ensure   => running,
        provider => 'systemd',
        require  => [ File[$logs_dir], Maven[$application_war_file] ],
    }

}

