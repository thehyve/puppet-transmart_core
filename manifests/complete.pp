class transmart_core::complete inherits transmart_core::params {

    $application_war_file = "${::home}/transmart-app.war"

    # Create transmart user.
    user { $::user:
        ensure     => present,
        home       => $::home,
        managehome => true,
    }

    # Make home only accessible for the user
    file { $::home:
        mode    => '0700',
        require => User[$::user],
    }

}

