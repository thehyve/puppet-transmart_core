class transmart_core::solr inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::data

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $tsdata_tar_file = $::transmart_core::params::tsdata_tar_file
    $tsdata_dir = $::transmart_core::params::tsdata_dir
    $solr_script = "${home}/solr"
    $solr_log_file = '/var/log/solr.log'

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
        notify  => Service['transmart-app'],
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
        require  => [ Archive::Nexus[$tsdata_tar_file] ],
    }

}

