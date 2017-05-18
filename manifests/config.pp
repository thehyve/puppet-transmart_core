class transmart_core::config inherits transmart_core::params {
  require transmart_core
  
  File {
      owner   => $::transmart_core::params::user,
      group   => $::transmart_core::params::user,
      require => User[$::transmart_core::params::user],
  }

  file { "/home/ewelina/vars":
      ensure  => file,
      content => template("transmart_core/tsdata-vars.erb"),
      mode    => '0700',
      # require => Archive::Nexus...,
  }
}
