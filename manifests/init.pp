# Class: transmart_core
# ===========================
#
# Full description of class transmart_core here.
#
# Parameters
# ----------
#
# * `user`
# The system user to be created that runs the application (default: transmart).
#
# * `user_home`
# The home directory where the application files are stored (default: /home/${user}).
#
# * `version`
# Version of the TranSMART artefacts in Nexus (default: 17.1-RC1).
#
# * `nexus_url`
# The url of the repository to fetch the TranSMART artefacts from
# (default: https://repo.thehyve.nl).
#
# * `db_user`
# The database user. Required.
#
# * `db_password`
# The database user's password. Required.
#
# * `db_type`
# 'postgresql' or 'oracle' (default: postgresql).
#
# * `db_host`
# The hostname of the database server (default: localhost).
#
# * `db_port_spec`
# The port of the database server (default: 5322 if postgres, 1521 if oracle).
#
# * `db_name_spec`
# The name of the application database (default: transmart).
#
# Examples
# --------
#
# @example
#    class { 'transmart_core':
#      version => '17.1-PRERELEASE',
#    }
#
# Authors
# -------
#
# Ewelina Grudzień <ewelina@thehyve.nl>
# Gijs Kant <gijs@thehyve.nl>
#
# Copyright
# ---------
#
# Copyright 2017 The Hyve.
#
class transmart_core inherits transmart_core::params {

    $user = $::transmart_core::params::user
    $home = $::transmart_core::params::tsuser_home

    # Create transmart user.
    user { $user:
        ensure     => present,
        home       => $home,
        managehome => true,
    }
    # Make home only accessible for the user
    -> file { $home:
        ensure => directory,
        mode   => '0711',
        owner  => $user,
    }

    case $::osfamily {
        'redhat': {
            $default_java = 'java-1.8.0-openjdk'
        }
        'debian': {
            $default_java = 'openjdk-8-jdk'
        }
        default: {
            $default_java = 'openjdk-8-jdk'
        }
    }

    if !defined('::java') {
        class { '::java':
            package => lookup('java::package', String, first, $default_java),
        }
    }
}
