# == Class: lxc::params
#
# This class defines defaults based on $::operatingsystem.
#
# === Authors
#
# Sergio Jimenez <tripledes@gmail.com>
#
# === Copyright
#
# Copyright 2014 Sergio Jimenez unless otherwise noted.
#
class lxc::params {

  # Ruby bindings for ruby-lxc
  $lxc_ruby_bindings_provider        = 'gem'
  $lxc_ruby_bindings_package         = 'ruby-lxc'
  $lxc_ruby_bindings_version         = '1.2.0'

  # Lxc packages / service
  $lxc_lxc_package                   = 'lxc'
  $lxc_lxc_version                   = latest
  $lxc_lxcfs_package                 = 'lxcfs'
  $lxc_lxcfs_version                 = latest
  $lxc_lxc_service                   = 'lxc'
  $lxc_lxc_service_ensure            = running
  $lxc_lxc_service_enabled           = true

  # Lxc networking basics
  $lxc_networking_device_link        = 'br0'
  $lxc_networking_type               = 'veth'
  $lxc_networking_flags              = 'up'
  $lxc_networking_hwaddr             = '00:16:3e:xx:xx:xx'

  # Lxc networking NAT
  $lxc_networking_nat_enable         = false
  $lxc_networking_nat_bridge         = undef
  $lxc_networking_nat_address        = undef
  $lxc_networking_nat_mask           = undef
  $lxc_networking_nat_network        = undef
  $lxc_networking_nat_dhcp_range     = undef
  $lxc_networking_nat_max_hosts      = undef
  $lxc_networking_nat_update_dnsmasq = false
  $lxc_networking_nat_dnsmasq_conf   = undef

  # local params?
  $network_nat_conf                  = undef
  $network_nat_service               = undef
  $network_default_conf              = '/etc/lxc/default.conf'

  # Lxc networking bridge
  $lxc_networking_bridge_enable      = true #only enable if nat is disabled
  $lxc_bridge_package                = 'bridge-utils' #only enable if nat is disabled
  $lxc_networking_set_defaults       = false
}
