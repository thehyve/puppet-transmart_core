class transmart_core::backend inherits transmart_core::params {

    $home = "/home/${user}"
    $application_war_file = "${home}/transmart-app.war"

    # Download the application war
    maven { $application_war_file:
        id      => "org.transmartproject:transmartApp:${version}:war",
        repos   => "https://repo.thehyve.nl/content/repositories/snapshots/",
        ensure  => latest,
        require => [ File[$home], Class['maven::maven'] ],
    }

}

