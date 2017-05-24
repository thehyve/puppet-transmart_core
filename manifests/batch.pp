class transmart_core::batch inherits transmart_core::params {
    include ::transmart_core

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home
    $tsbatch_directory = "${home}/transmart-batch"
    $tsbatch_jar_file = "${tsbatch_directory}/transmart-batch.jar"

    file { $tsbatch_directory:
        ensure => directory,
        owner  => $user,
    }
    -> file { "${tsbatch_directory}/batchdb.properties":
        ensure  => file,
        content => template('transmart_core/config/batchdb.properties.erb'),
        owner   => $user,
        mode    => '0400',
    }

    # Download transmart-batch
    archive::nexus { $tsbatch_jar_file:
        user       => $::transmart_core::params::user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "org.transmartproject:transmart-batch:${::transmart_core::params::version}",
        repository => $::transmart_core::params::repository,
        packaging  => 'jar',
        owner      => $user,
        mode       => '0444',
        require    => File[$tsbatch_directory],
    }

}

