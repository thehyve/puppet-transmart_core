class transmart_core::config inherits transmart_core::params {
    require ::transmart_core

    $tsdata_dir = $::transmart_core::params::tsdata_dir

    File {
        owner   => $::transmart_core::params::user,
        group   => $::transmart_core::params::user,
        require => User[$::transmart_core::params::user],
    }

    file { "${tsdata_dir}/vars":
        ensure  => file,
        content => template('transmart_core/tsdata-vars.erb'),
        mode    => '0700',
        require => Archive::Nexus[$::transmart_core::params::tsdata_tar_file],
    }
}
