# == Define Resource Type: monit::check
#
# Puppet resource to add a Monit check
#
# === Parameters
#
# [*ensure*]
#   Whether the check should exist.
#   Default: present
#
# [*source*]
#   Path of the configuration file.
#   Exclusive with the `content` parameter.
#   Default: undef
#
# [*content*]
#   Content of the configuration file.
#   Exclusive with the `source` parameter.
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
  $ensure       = present,
  $source       = undef,
  $content      = undef,
  $package_name = 'monit',
  $service_name = 'monit',
) {
  validate_re (
    $ensure,
    '^(present|absent)$',
    "${ensure} is not supported for ensure. \
Allowed values are 'present' and 'absent'."
  )
  validate_string($package_name)
  validate_string($service_name)

  if $source and $content {
    fail 'Parameters source and content are mutually exclusive'
  }
  if $source {
    validate_string($source)
  }
  if $content {
    validate_string($content)
  }

  file { "/etc/monit/conf.d/${name}":
    ensure  => $ensure,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    source  => $source,
    content => $content,
    notify  => Service[$service_name],
    require => Package[$package_name],
  }
}
