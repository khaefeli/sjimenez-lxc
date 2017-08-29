# == Class: lxc::template
#
# This class manages the lxc template 
# and lxc default settings for container creation
#
class lxc::template {
  $set_defaults             = $lxc::lxc_networking_set_defaults
  $default_conf             = $lxc::network_default_conf

  # set networking defaults
  $networking_type          = $lxc::lxc_networking_type
  $networking_device_link   = $lxc::lxc_networking_device_link
  $networking_flags         = $lxc::lxc_networking_flags
  $networking_hwaddr        = $lxc::lxc_networking_hwaddr
  $networking_extra_options = $lxc::lxc_networking_extra_options

  # TODO: set other options (not only network related)

  # set default settings
  # A basic configuration is generated at container creation time with 
  # the default's recommended for the chosen template as well 
  # as extra default keys coming from the default.conf file. 
  if $set_defaults {
    file { $default_conf:
      ensure  => present,
      content => template("${module_name}/config/default.conf.erb"),
    }
  }

  # TODO: manage the lxc templates
  # for now: manage it in your profile 

}
