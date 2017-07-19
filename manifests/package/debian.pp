# == Class: lxc::package::debian
#
# This module manage LXC package installation of debian bases systems
# === Authors
#
# Kevin Häfeli <kevin@zattoo.com>
#
# === Copyright
#
# Copyright 2017 Kevin Häfeli, unless otherwise noted.
#

class lxc::package::debian {

  # set the params for the local scope
  $package_name      = $::lxc::lxc_lxc_package
  $package_ensure    = $::lxc::lxc_lxc_version
  $bindings_deps     = 'build-essential', 'ruby-dev', 'lxc-dev', 'libcgmanager0' #defined here for debian (only support ruby so far)
  $bindings_ensure   = 'present' 
  $bindings_version  = $::lxc::lxc_ruby_bindings_version 
  $bindings_package  = $::lxc::lxc_ruby_bindings_package
  $bindings_provider = $::lxc::lxc_ruby_bindings_provider
  $tag               = 'lxc_packages'

  # install lxc base package
  package { 'lxc':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => $tag,
    notify => Class['lxc::service'],
  }

  # install lxc bindings dependencies
  package { $bindings_deps:
    ensure => $bindings_ensure,
    tag    => $tag,
  }

  # install the ruby-lxc module for the lxc provider 
  # See more: https://github.com/lxc/ruby-lxc
  # TODO: Support Go, phyton and other bindings
  # Go: https://github.com/lxc/go-lxc
  package { 'lxc-bindings':
    ensure   => $bindings_version,
    name     => $bindings_package,
    provider => $bindings_provider,
    require  => Package['lxc', $bindings_deps],
  }
}
