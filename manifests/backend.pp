# Copyright 2017 The Hyve.
class transmart_core::backend inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $version = $::transmart_core::params::version
    $application_war_file = "${home}/transmart-server-${version}.war"
    $memory = $::transmart_core::params::memory
    $java_opts = "-server -Xms${memory} -Xmx${memory} -Djava.awt.headless=true -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true "
    $app_port = $::transmart_core::params::app_port
    $app_opts = "-Dserver.port=${app_port} -Djava.security.egd=file:///dev/urandom "
    $start_script = "${home}/start"
    $logs_dir = "${home}/logs"
    $jobs_dir = $::transmart_core::params::jobs_directory

    Archive::Nexus {
        owner   => $user,
        group   => $user,
    }

    # Download the application war
    archive::nexus { $application_war_file:
        user       => $user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "org.transmartproject:transmart-server:${version}",
        repository => $::transmart_core::params::repository,
        packaging  => 'war',
        mode       => '0444',
        creates    => $application_war_file,
        require    => File[$home],
        notify     => Service['transmart-server'],
        cleanup    => false,
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
        notify  => Service['transmart-server'],
    }
    -> file { '/etc/systemd/system/transmart-server.service':
        ensure  => file,
        mode    => '0644',
        content => template('transmart_core/service/transmart-server.service.erb'),
        notify  => Service['transmart-server'],
    }
    # Start the application service
    -> service { 'transmart-server':
        ensure   => running,
        provider => 'systemd',
        require  => [ File[$logs_dir], File[$jobs_dir], Archive::Nexus[$application_war_file] ],
    }

}

