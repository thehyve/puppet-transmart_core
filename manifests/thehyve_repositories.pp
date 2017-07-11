# Copyright 2017 The Hyve.
class transmart_core::thehyve_repositories {
    if $::osfamily == 'Debian' {
        require ::apt

        if $::lsbdistcodename == 'trusty' {
            $release = 'trusty'
        } elsif $::lsbdistcodename == 'xenial' {
            $release = 'xenial'
        } else {
            $release = undef
        }

        if $release != '' {
            apt::source { 'thehyve_internal':
                location    => 'http://apt.thehyve.net/internal/',
                release     => $release,
                repos       => 'main',
                key         => '79cbff36340878cfb6a09bbecf5b7bd93375da21',
                key_server  => 'keyserver.ubuntu.com',
                include_src => false,
            }
        }

        Class['apt::update'] -> Package <| provider != 'pip' and
                                            provider != 'pip3' and
                                            provider != 'dpkg' and
                                            provider != 'gem' and
                                            title != 'apt-transport-https' |>
    } elsif $::osfamily == 'RedHat' {
        yumrepo { 'thehyve_internal':
            baseurl  => 'https://repo.thehyve.nl/content/repositories/releases',
            descr    => 'The Hyve Internal RPM releases',
            enabled  => 1,
            gpgcheck => 0,
        } -> Package <| provider != 'pip' and provider != 'pip3' and provider != 'rpm' and provider != 'gem'  |>
    }
}

