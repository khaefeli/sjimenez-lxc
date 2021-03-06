# == Class: lxc::package
#
# This module manage LXC package installation bases on $::os
#
# === Authors
#
# Kevin Häfeli <kevin@zattoo.com>
#
# === Copyright
#
# Copyright 2017 Kevin Häfeli, unless otherwise noted.
#

class lxc::package {

  # Check for supported OS
  case $::os['family'] {
    'Ubuntu': {
      contain ::lxc::package::ubuntu
    }
    'Debian': {
      contain ::lxc::package::debian
    }
    default: {
      fail("${::os['family']} is not supported by ${module_name}.")
    }
  }
}
