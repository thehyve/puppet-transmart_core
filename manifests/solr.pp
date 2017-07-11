class transmart_core::solr inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::data

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $solr_tar_file = "${home}/transmart-data-${::transmart_core::params::version}-solr.tar"
    $solr_dir = "${home}/transmart-data-solr-${::transmart_core::params::version}"
    $solr_script = "${home}/solr"
    $solr_log_file = '/var/log/solr.log'

    # Download and untar transmart-data-solr
    archive::nexus { $solr_tar_file:
        user         => $user,
        url          => $::transmart_core::params::nexus_url,
        gav          => "org.transmartproject:transmart-data-solr:${::transmart_core::params::version}",
        repository   => $::transmart_core::params::repository,
        packaging    => 'tar',
        extract      => true,
        extract_path => $home,
        creates      => $solr_dir,
        cleanup      => true,
    }

    file { $solr_log_file:
        ensure => file,
        owner  => $user,
        mode   => '0622',
    }
    -> file { $solr_script:
        ensure  => file,
        owner   => $user,
        mode    => '0744',
        content => template('transmart_core/solr.erb'),
        notify  => Service['transmart-server'],
    }
    -> file { '/etc/systemd/system/transmart-solr.service':
        ensure  => file,
        mode    => '0644',
        content => template('transmart_core/service/transmart-solr.service.erb'),
        notify  => Service['transmart-solr'],
    }
    # Start the Solr service
    -> service { 'transmart-solr':
        ensure   => running,
        provider => 'systemd',
        require  => [ Archive::Nexus[$solr_tar_file] ],
    }

}

