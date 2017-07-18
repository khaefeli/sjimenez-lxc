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

  $local_lxc_networking_extra_options = $lxc::lxc_networking_extra_options
  $local_lxc_set_defaults = $lxc::lxc_networking_set_defaults

  file { $lxc::params::network_default_conf:
    ensure  => present,
    content => template("${module_name}/config/default.conf.erb"),
  }
}
