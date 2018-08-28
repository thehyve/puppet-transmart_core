# Copyright 2017 The Hyve.
class transmart_core::config inherits transmart_core::params {
    include ::transmart_core

    File {
        owner   => $::transmart_core::params::user,
        group   => $::transmart_core::params::user,
        require => User[$::transmart_core::params::user],
    }

    if ($::transmart_core::params::server_type == 'api-server') {

        if ($::transmart_core::params::keycloak_disable_trust_manager) {
            notify { "Warning: certificate checking for Keycloak on ${::hostname} is disabled! NEVER DO THIS IN PRODUCTION!": }
        }

        file { "${::transmart_core::params::tsuser_home}/transmart-api-server.config.yml":
            ensure  => file,
            content => template('transmart_core/config/transmart-api-server/config.yml.erb'),
            mode    => '0400',
        }
    } else {
        $config_prefix = "${::transmart_core::params::tsuser_home}/.grails/transmartConfig"
        file { ["${::transmart_core::params::tsuser_home}/.grails", $config_prefix]:
            ensure => directory,
            mode   => '0700',
        }
        -> file { "${config_prefix}/application.groovy":
            ensure  => file,
            content => template('transmart_core/config/transmart-server/application.groovy.erb'),
            mode    => '0400',
        }
    }

}
