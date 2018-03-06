# Copyright 2017 The Hyve.
class transmart_core::thehyve_repositories {
    if $::osfamily == 'Debian' {
        require ::apt

        case $::lsbdistcodename {
            'trusty': {
                $release = 'trusty'
            }
            'xenial', 'artful': {
                $release = 'xenial'
            }
            default: {
                $release = undef
            }
        }

        if $release != '' {
            apt::source { 'thehyve_internal':
                location => 'http://apt.thehyve.net/internal/',
                release  => $release,
                repos    => 'main',
                key      => {
                    'id'     => '79cbff36340878cfb6a09bbecf5b7bd93375da21',
                    'server' => 'keyserver.ubuntu.com',
                },
                include  => {
                    'src' => false,
                },
            }
        }

        Class['apt::update'] -> Package <| provider != 'pip' and
                                            provider != 'pip3' and
                                            provider != 'dpkg' and
                                            provider != 'gem' and
                                            title != 'dirmngr' and
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

