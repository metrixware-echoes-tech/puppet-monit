# == Define Resource Type: monit::check
#
# Püppet resource to add a Monit check
#
# === Parameters
#
# [*source*]
#   Path of the configuration file.
#   Default: undef
#
# [*package_name*]
#   Name parameter passed to Monit Package[] resource.
#   Default: 'monit'
#
# [*service_name*]
#   Name parameter passed to Monit Service[] resource.
#   Default: 'monit'
#
# === Examples
#
#  monit::check { 'ntp':
#    source => "puppet:///modules/${module_name}/ntp",
#  }
#
# to disable current monit::check set ```ensure => absent```
#
# === Authors
#
# Florent Poinsaut <florent.poinsaut@echoes-tech.com>
#
# === Copyright
#
# Copyright 2014 Echoes Technologies SAS, unless otherwise noted.
#
define monit::check (
  $source       = undef,
  $package_name = 'monit',
  $service_name = 'monit',
  $ensure       = present
) {
  validate_string($source)
  validate_array($package_name)
  validate_string($service_name)
  validate_re($ensure, '^(present|absent)$',
    "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  file { "/etc/monit/conf.d/${name}":
    owner   => 0,
    group   => 0,
    mode    => '0644',
    source  => $source,
    ensure  => $ensure,
    notify  => Service[$service_name],
    require => Package[$package_name],
  }
}
