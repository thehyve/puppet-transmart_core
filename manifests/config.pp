class transmart_core::config inherits transmart_core::params {
    include ::transmart_core

    $config_prefix = "${::transmart_core::params::tsuser_home}/.grails/transmartConfig"

    File {
        owner   => $::transmart_core::params::user,
        group   => $::transmart_core::params::user,
        require => User[$::transmart_core::params::user],
    }

    file { ["${::transmart_core::params::tsuser_home}/.grails", $config_prefix]:
        ensure => directory,
        mode   => '0700',
    }
    -> file { "${config_prefix}/application.groovy":
        ensure  => file,
        content => template('transmart_core/config/application.groovy.erb'),
        mode    => '0400',
    }

}
