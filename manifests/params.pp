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
# Copyright 2014 Sergio Jimenez, unless otherwise noted.
#
class lxc::params (
  $lxc_ruby_bindings_provider        = gem,
  $lxc_ruby_bindings_package         = 'ruby-lxc',
  $lxc_ruby_bindings_version         = '1.2.0',
  $lxc_lxc_package                   = 'lxc',
  $lxc_lxc_version                   = latest,
  $lxc_lxc_service                   = 'lxc',
  $lxc_lxc_service_ensure            = running,
  $lxc_lxc_service_enabled           = true,
  $lxc_cgmanager_service             = 'cgmanager',
  $lxc_cgmanager_service_ensure      = running,
  $lxc_cgmanager_service_enabled     = true,
  $lxc_networking_device_link        = 'br0',
  $lxc_networking_type               = 'veth',
  $lxc_networking_flags              = 'up',
  $lxc_networking_hwaddr             = '00:16:3e:xx:xx:xx',
  $lxc_networking_nat_enable         = false,
  $lxc_networking_nat_bridge         = undef,
  $lxc_networking_nat_address        = undef,
  $lxc_networking_nat_mask           = undef,
  $lxc_networking_nat_network        = undef,
  $lxc_networking_nat_dhcp_range     = undef,
  $lxc_networking_nat_max_hosts      = undef,
  $lxc_networking_nat_update_dnsmasq = false,
  $lxc_networking_nat_dnsmasq_conf   = undef,
  $network_default_conf              = '/etc/lxc/default.conf',
  $network_nat_conf                  = undef,
  $network_nat_service               = undef,
  ) {
  case $::operatingsystem {
    'Ubuntu': {
      case $::lsbdistcodename {
        'trusty': {
          $lxc_ruby_bindings_gem_deps = [
            'build-essential', 'ruby-dev', 'lxc-dev', 'libcgmanager0'
          ]
        }
        default: {
          fail("Ubuntu ${::lsbdistcodename} is not supported by ${module_name}.")
        }
      }
    }
    'Debian': {
      case $::operatingsystemmajrelease {
        '6': { error ('debian squeeze is not supported') }
        '7': { error ('debian wheezy is not supported') }
        '8': { 
          $lxc_ruby_bindings_gem_deps = [
            'build-essential', 'ruby-dev', 'lxc-dev', 'libcgmanager0'
          ]
        }
      }
    }
    default: {
        fail("${::operatingsystem} is not supported by ${module_name} module.")
    }
  }

}
