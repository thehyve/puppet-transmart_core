class transmart_core::params(
    String $user               = hiera('transmart_core::user', 'transmart'),
    String $home               = hiera('transmart_core::home', "/home/${user}"),
    String $version            = hiera('transmart_core::version', 'latest'),
    String $nexus_repository   = hiera('transmart_core::nexus_repository', 'https://repo.thehyve.nl'),
) {
}

