class apt::params {

    if $::osfamily != 'Debian' {
        fail('This module only works on Debian or derivatives like Ubuntu')
    }
}

