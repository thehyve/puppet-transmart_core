# Class: transmart_core
# ===========================
#
# Full description of class transmart_core here.
#
# Parameters
# ----------
#
# * `nexus_repository`
# The url of the repository to fetch the TranSMART artefacts from
# (default: https://repo.thehyve.nl).
#
# * `version`
# Version of the TranSMART artefacts in Nexus (default: latest).
#
# Examples
# --------
#
# @example
#    class { 'transmart_core':
#      nexus_repository => 'https://repo.thehyve.nl',
#    }
#
# Authors
# -------
#
# Gijs Kant <gijs@thehyve.nl>
#
# Copyright
# ---------
#
# Copyright 2017 The Hyve.
#
class transmart_core {
   include transmart_core::params

   # Create transmart user.
    user { $::transmart_core::params::user:
        ensure => present,
        home   => $::transmart_core::params::tsuser_home,
        managehome => true,
    }

    class { 'java':
    }

    class { 'maven::maven':
        version => '3.0.5',
    }

}

