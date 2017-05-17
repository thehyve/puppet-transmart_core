class transmart_core::params(
    $user               = hiera('transmart_core::user', 'transmart'),
    $version            = hiera('transmart_core::version', 'latest'),
    $nexus_repository   = hiera('transmart_core::nexus_repository', 'https://repo.thehyve.nl'),
) {
}

