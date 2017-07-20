# == Class: lxc::networking
#
# This class manages the networking / interfaces settings
#
class lxc::networking {

  $device_link = $lxc::lxc_networking_device_link
  $networking_extra_options = $lxc::lxc_networking_extra_options
  $set_defaults = $lxc::lxc_networking_set_defaults
  $nat_enable = $lxc::lxc_networking_nat_enable
  $bridge_enable = $lxc::lxc_networking_bridge_enable
  $default_conf = $lxc::params::network_default_conf

  # set networking defaults
  $networking_type = $lxc::lxc_networking_type
  $networking_device_link = $lxc::lxc_networking_device_link
  $networking_flags = $lxc::lxc_networking_flags
  $networking_type = $lxc::lxc_networking_hwaddr

  # contain NAT independent bridge (masqueraded bridge)) 
  if $nat_enable {
    contain '::lxc::networking::nat'
  }

  # contain host-shared bridge
  if $bridge_enable {
    contain '::lxc::networking::bridge'
  }

  # check if networking is setup
  if empty($device_link) and empty($networking_type) {
    fail('lxc_networking_device_link and lxc_networking_type are required')
  }
}
