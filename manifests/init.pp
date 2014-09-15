# == Class: monit
#
# Puppet module to manage monit installation and configuration
#
# === Parameters
#
# [*check_interval*]
#   Interval between two checks of Monit.
#   Default: 120
#
# [*httpd*]
#   If true, Puppet enables the Monit Dashboard
#   Default: false
#
# [*httpd_port*]
#   Port of the Monit Dashboard
#   Default: 2812
#
# [*httpd_address*]
#   IP address of the Monit Dashboard
#   Default: 'locahost'
#
# [*httpd_user*]
#   User to access the Monit Dashboard
#   Default: 'admin'
#
# [*httpd_password*]
#   Password to access the Monit Dashboard
#   Default: 'monit'
#
# [*manage_firewall*]
#   If true and if puppetlabs-firewall module is present,
#   Puppet manages firewall to allow HTTP access for Monit Dashboard.
#   Default: true
#
# [*package_ensure*]
#   Ensure parameter passed to Monit Package[] resource.
#   Default: 'present'
#
# [*package_name*]
#   Name parameter passed to Monit Package[] resource.
#   Default: 'monit'
#
# [*service_ensure*]
#   Ensure parameter passed to Monit Service[] resource.
#   Default: 'running'
#
# [*service_manage*]
#   If true, Puppet manages Monit service state
#   Default: true
#
# [*service_name*]
#   Name parameter passed to Monit Service[] resource.
#   Default: 'monit'
#
# === Examples
#
#  class { 'monit':
#    check_interval => 60,
#    httpd          => true,
#    httpd_address  => '172.16.0.3',
#    httpd_password => 'CHANGE_ME',
#  }
#
# === Authors
#
# Florent Poinsaut <florent.poinsaut@echoes-tech.com>
#
# === Copyright
#
# Copyright 2014 Echoes Technologies SAS, unless otherwise noted.
#
class monit (
  $check_interval  = $monit::params::check_interval,
  $httpd           = $monit::params::httpd,
  $httpd_port      = $monit::params::httpd_port,
  $httpd_address   = $monit::params::httpd_address,
  $httpd_user      = $monit::params::httpd_user,
  $httpd_password  = $monit::params::httpd_password,
  $manage_firewall = $monit::params::manage_firewall,
  $package_ensure  = $monit::params::package_ensure,
  $package_name    = $monit::params::package_name,
  $service_enable  = $monit::params::service_enable,
  $service_ensure  = $monit::params::service_ensure,
  $service_manage  = $monit::params::service_manage,
  $service_name    = $monit::params::service_name,
) inherits monit::params {
  if ! is_integer($check_interval) {
    fail('Invalid type. check_interval param should be an integer.')
  }
  validate_bool($httpd)
  if ! is_integer($httpd_port) {
    fail('Invalid type. http_port param should be an integer.')
  }
  validate_string($httpd_address)
  validate_string($httpd_user)
  validate_string($httpd_password)
  validate_bool($manage_firewall)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)

  anchor { "${module_name}::begin": } ->
  class { "${module_name}::install": } ->
  class { "${module_name}::config": } ~>
  class { "${module_name}::service": } ->
  class { "${module_name}::firewall": }->
  anchor { "${module_name}::end": }
}
