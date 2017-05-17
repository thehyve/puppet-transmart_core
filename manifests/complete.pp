class transmart_core::complete inherits transmart_core::params {

    $home = "/home/${user}"
    $application_war_file = "${home}/transmart-app.war"

    # Create transmart user.
    user { $user:
        ensure     => present,
        home       => $home,
        managehome => true,
    }

    # Make home only accessible for the user
    file { $home:
        ensure  => directory,
        mode    => '0700',
        owner   => $user,
        require => User[$user],
    }

}

