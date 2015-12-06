# == Class: monit
#
class monit (
  $check_interval            = 120,
  $httpd                     = false,
  $httpd_port                = 2812,
  $httpd_address             = 'localhost',
  $httpd_user                = 'admin',
  $httpd_password            = 'monit',
  $manage_firewall           = false,
  $package_ensure            = 'present',
  $package_name              = 'monit',
  $service_enable            = true,
  $service_ensure            = 'running',
  $service_manage            = true,
  $service_name              = 'monit',
  $logfile                   = '/var/log/monit.log', # now also accepts 'syslog'
  $mailserver                = undef,
  $mailformat                = undef,
  $alert_emails              = [],
  $start_delay               = 0,
  $mmonit_address            = undef,
  $mmonit_port               = '8080',
  $mmonit_user               = 'monit',
  $mmonit_password           = 'monit',
  $mmonit_without_credential = false,
  $config_file               = 'USE_DEFAULTS', # additional param to be documented
  $config_dir                = 'USE_DEFAULTS', # additional param to be documented
  $config_dir_purge          = false, # additional param to be documented
) {

  validate_integer($check_interval)
  validate_bool($httpd)
  validate_integer($httpd_port)
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

  if $logfile != 'syslog' {
    validate_absolute_path($logfile)
  }

  if $mailserver != undef {
    validate_string($mailserver)
  }

  if $mailformat != undef {
    validate_hash($mailformat)
  }

  validate_array($alert_emails)

  if $mmonit_address != undef {
    validate_string($mmonit_address)
  }

  validate_string($mmonit_port)
  validate_string($mmonit_user)
  validate_string($mmonit_password)
  validate_bool($mmonit_without_credential)

  if is_string($config_dir_purge) == true {
    $config_dir_purge_bool = str2bool($config_dir_purge)
  } else {
    $config_dir_purge_bool = $config_dir_purge
  }
  validate_bool($config_dir_purge_bool)

  case $::osfamily {
    default: {
      fail("monit supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
    'Debian': {
      $monit_version       = '5'
      $default_config_file = '/etc/monit/monitrc'
      $default_config_dir  = '/etc/monit/conf.d'

      case $::lsbdistcodename {
        default: {
          fail("monit supports Debian 6 (squeeze) and 7 (wheezy) and Ubuntu 10.04 (lucid), 12.04 (precise) and 14.04 (trusty). Detected lsbdistcodename is <${::lsbdistcodename}>.")
        }
        'squeeze', 'lucid': {
          $default_file_content = 'startup=1'
          $service_hasstatus    = false
        }
        'wheezy','precise','trusty': {
          $default_file_content = 'START=yes'
          $service_hasstatus    = true
        }
      }
    }
    'RedHat': {
      $service_hasstatus  = true
      $default_config_dir = '/etc/monit.d'

      case $::operatingsystemmajrelease {
        default: {
          fail("monit supports EL 5, 6 and 7. Detected operatingsystemmajrelease is <${::operatingsystemmajrelease}>.")
        }
        '5': {
          $monit_version       = '4'
          $default_config_file = '/etc/monit.conf'
        }
        '6': {
          $monit_version       = '5'
          $default_config_file = '/etc/monit.conf'
        }
        '7': {
          $monit_version       = '5'
          $default_config_file = '/etc/monitrc'
        }
      }
    }
  }

  validate_integer($start_delay, '', 0)

  # Use the monit_version fact if available, else use the default for the
  # platform.
  if $::monit_version {
    $monit_version_real = $::monit_version
  } else {
    $monit_version_real = $monit_version
  }

  if($start_delay + 0 > 0 and versioncmp($monit_version_real,'5') < 0) {
    fail("start_delay requires at least Monit 5.0. Detected version is <${monit_version_real}>.")
  }

  if $config_dir == 'USE_DEFAULTS' {
    $config_dir_real = $default_config_dir
  } else {
    $config_dir_real = $config_dir
  }
  validate_absolute_path($config_dir_real)

  if $config_file == 'USE_DEFAULTS' {
    $config_file_real = $default_config_file
  } else {
    $config_file_real = $config_file
  }
  validate_absolute_path($config_file_real)

  package { 'monit':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { '/var/lib/monit':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { 'monit_config_dir':
    ensure  => directory,
    path    => $config_dir_real,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => $config_dir_purge_bool,
    recurse => $config_dir_purge_bool,
    require => Package['monit'],
  }

  file { 'monit_config':
    ensure  => file,
    path    => $config_file_real,
    content => template('monit/monitrc.erb'),
    owner   => 0,
    group   => 0,
    mode    => '0600',
    require => Package['monit'],
  }

  if $service_manage {
    if $::osfamily == 'Debian' {
      file { '/etc/default/monit':
        content => $default_file_content,
        before  => Service['monit'],
      }
    }

    service { 'monit':
      ensure     => $service_ensure,
      name       => $service_name,
      enable     => $service_enable,
      hasrestart => true,
      hasstatus  => $service_hasstatus,
      subscribe  => [
        File['/var/lib/monit'],
        File['monit_config_dir'],
        File['monit_config'],
      ],
    }
  }

  if $httpd and $manage_firewall {
    if defined('::firewall') {
      firewall { "${httpd_port} allow Monit inbound traffic":
        action => 'accept',
        dport  => $httpd_port,
        proto  => 'tcp',
      }
    }
  }
}
