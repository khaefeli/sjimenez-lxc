# == Class: lxc::networking::containers
#
# This class manages the default networking settings for containers.
#
# === Authors
#
# Sergio Jimenez <tripledes@gmail.com>
#
# === Copyright
#
# Copyright 2014 Sergio Jimenez, unless otherwise noted.
#
class lxc::networking::containers inherits lxc::params {

  assert_private()

  if empty($lxc::lxc_networking_device_link) and
    empty($lxc::lxc_networking_type) {
    fail('lxc_networking_device_link and lxc_networking_type are required')
  }

}
