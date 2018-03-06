# Copyright 2017 The Hyve.
class transmart_core::batch inherits transmart_core::params {
    include ::transmart_core

    $tsloader_user = $::transmart_core::params::tsloader_user
    $tsloader_home = $::transmart_core::params::tsloader_home
    $tsbatch_directory = "${tsloader_home}/transmart-batch"
    $version = $::transmart_core::params::version
    $tsbatch_jar_filename = "transmart-batch-${version}.jar"
    $tsbatch_jar_file = "${tsbatch_directory}/${tsbatch_jar_filename}"
    $properties_filename = 'batchdb.properties'
    $properties_file = "${tsbatch_directory}/${properties_filename}"

    File {
        owner   => $tsloader_user,
        group   => $tsloader_user,
        require => User[$tsloader_user],
    }
    Archive::Nexus {
        owner   => $tsloader_user,
        group   => $tsloader_user,
    }

    file { $tsbatch_directory:
        ensure => directory,
    }
    -> file { $properties_file:
        ensure  => file,
        content => template('transmart_core/config/batchdb.properties.erb'),
        mode    => '0400',
    }
    -> file { "${tsbatch_directory}/transmart-batch":
        ensure  => file,
        content => template('transmart_core/transmart-batch.erb'),
        mode    => '0755',
    }

    # Download transmart-batch
    archive::nexus { $tsbatch_jar_file:
        user       => $tsloader_user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "org.transmartproject:transmart-batch:${version}",
        repository => $::transmart_core::params::repository,
        packaging  => 'jar',
        mode       => '0444',
        creates    => $tsbatch_jar_file,
        require    => File[$tsbatch_directory],
        cleanup    => false,
    }

}

