class transmart_core::data inherits transmart_core::params {

    $home = $::transmart_core::params::tmuser_home
    $tsdata_tar_file = $::transmart_core::params::tsdata_tar_file
    $tsdata_dir = $::transmart_core::params::tsdata_dir

    # Download and untar transmart-data
    archive::nexus { $tsdata_tar_file:
        user         => $user,
        url          => 'https://repo.thehyve.nl',
        gav          => "org.transmartproject:transmart-data:${version}",
        repository   => 'snapshots',
        packaging    => 'tar',
        extract      => true,
        extract_path => $home,
        creates      => $tsdata_dir,
        cleanup      => true,
    }

}

