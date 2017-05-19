class transmart_core::data inherits transmart_core::params {
    include ::transmart_core

    $home = $::transmart_core::params::tmuser_home
    $tsdata_tar_file = $::transmart_core::params::tsdata_tar_file
    $tsdata_dir = $::transmart_core::params::tsdata_dir

    # Download and untar transmart-data
    archive::nexus { $tsdata_tar_file:
        user         => $::transmart_core::params::user,
        url          => $::transmart_core::params::nexus_url,
        gav          => "org.transmartproject:transmart-data:${::transmart_core::params::version}",
        repository   => $::transmart_core::params::repository,
        packaging    => 'tar',
        extract      => true,
        extract_path => $home,
        creates      => $tsdata_dir,
        cleanup      => true,
    }

}

