# Copyright 2017 The Hyve.
class transmart_core::data inherits transmart_core::params {
    include ::transmart_core

    $tsloader_user = $::transmart_core::params::tsloader_user
    $tsloader_home = $::transmart_core::params::tsloader_home
    $tsdata_tar_file = $::transmart_core::params::tsdata_tar_file
    $tsdata_dir = $::transmart_core::params::tsdata_dir

    File {
        owner   => $tsloader_user,
        group   => $tsloader_user,
        require => User[$tsloader_user],
    }
    Archive::Nexus {
        owner   => $tsloader_user,
        group   => $tsloader_user,
    }

    $db_user = $::transmart_core::params::db_user
    $db_password = $::transmart_core::params::db_password

    if ($db_user == '') {
        fail('No database user specified. Please configure transmart_core::db_user')
    }
    if ($db_password == '') {
        fail('No database password specified. Please configure transmart_core::db_password')
    }

    # Download and untar transmart-data
    archive::nexus { $tsdata_tar_file:
        user         => $tsloader_user,
        url          => $::transmart_core::params::nexus_url,
        gav          => "org.transmartproject:transmart-data:${::transmart_core::params::version}",
        repository   => $::transmart_core::params::repository,
        packaging    => 'tar',
        extract      => true,
        extract_path => $tsloader_home,
        creates      => $tsdata_dir,
        cleanup      => true,
    }
    # Create database configuration file for transmart-data
    -> file { "${tsdata_dir}/vars":
        ensure  => file,
        content => template('transmart_core/config/tsdata-vars.erb'),
        mode    => '0400',
    }

    # Dependencies for transmart-data
    package { 'make': }
    package { 'groovy': }
    package { 'php': }

    # Download jars required by transmart-data
    $maven_cache_dir = "${tsloader_home}/.m2/repository"
    #    file { $maven_cache_dir:
    #    ensure  => directory,
    #    recurse => true,
    #    mode    => '0755',
    #    owner   => $user,
    #}

    $jackson_version = '1.9.13'
    $jackson_core_jar = "${maven_cache_dir}/org/codehaus/jackson/jackson-core-asl/${jackson_version}/jackson-core-asl-${jackson_version}.jar"
    archive::nexus { $jackson_core_jar:
        user       => $tsloader_user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "org.codehaus.jackson:jackson-core-asl:${jackson_version}",
        repository => 'releases',
        packaging  => 'jar',
        mode       => '0444',
        creates    => $jackson_core_jar,
        cleanup    => false,
    }
    $jackson_mapper_jar = "${maven_cache_dir}/org/codehaus/jackson/jackson-mapper-asl/${jackson_version}/jackson-mapper-asl-${jackson_version}.jar"
    archive::nexus { $jackson_mapper_jar:
        user       => $tsloader_user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "org.codehaus.jackson:jackson-mapper-asl:${jackson_version}",
        repository => 'releases',
        packaging  => 'jar',
        mode       => '0444',
        creates    => $jackson_mapper_jar,
        cleanup    => false,
    }
    $opencsv_version = '2.3'
    $opencsv_jar = "${maven_cache_dir}/net/sf/opencsv/opencsv/${opencsv_version}/opencsv-${opencsv_version}.jar"
    archive::nexus { $opencsv_jar:
        user       => $tsloader_user,
        url        => $::transmart_core::params::nexus_url,
        gav        => "net.sf.opencsv:opencsv:${opencsv_version}",
        repository => 'releases',
        packaging  => 'jar',
        mode       => '0444',
        creates    => $opencsv_jar,
        cleanup    => false,
    }

}

