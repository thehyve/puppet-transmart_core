class transmart_core::backend inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $application_war_file = "${home}/transmart-app.war"
    $memory = $::transmart_core::params::memory
    $java_opts = "-server -Xms${memory} -Xmx${memory} -Djava.awt.headless=true -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true "
    $app_port = $::transmart_core::params::app_port
    $app_opts = "-Dserver.port=${app_port} -Djava.security.egd=file:///dev/urandom "
    $start_script = "${home}/start"
    $logs_dir = "${home}/logs"
    $jobs_dir = $::transmart_core::params::jobs_directory

    # Download the application war
    maven { $application_war_file:
        ensure  => latest,
        user    => $user,
        id      => "org.transmartproject:transmartApp:${::transmart_core::params::version}:war",
        repos   => $::transmart_core::params::nexus_repository,
        require => [ File[$home], Class['maven::maven'] ],
    }
    file { $logs_dir:
        ensure => directory,
        owner  => $user,
        mode   => '0700',
    }
    file { $jobs_dir:
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
        content => template('transmart_core/service/transmart-app.service.erb'),
        notify  => Service['transmart-app'],
    }
    # Start the application service
    -> service { 'transmart-app':
        ensure   => running,
        provider => 'systemd',
        require  => [ File[$logs_dir], File[$jobs_dir], Maven[$application_war_file] ],
    }

}

