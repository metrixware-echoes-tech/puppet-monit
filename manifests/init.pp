# == Class: monit
#
class monit (
  $check_interval            = $monit::params::check_interval,
  $httpd                     = $monit::params::httpd,
  $httpd_port                = $monit::params::httpd_port,
  $httpd_address             = $monit::params::httpd_address,
  $httpd_user                = $monit::params::httpd_user,
  $httpd_password            = $monit::params::httpd_password,
  $manage_firewall           = $monit::params::manage_firewall,
  $package_ensure            = $monit::params::package_ensure,
  $package_name              = $monit::params::package_name,
  $service_enable            = $monit::params::service_enable,
  $service_ensure            = $monit::params::service_ensure,
  $service_manage            = $monit::params::service_manage,
  $service_name              = $monit::params::service_name,
  $config_file               = $monit::params::config_file,
  $config_dir                = $monit::params::config_dir,
  $config_dir_purge          = $monit::params::config_dir_purge,
  $logfile                   = $monit::params::logfile,
  $mailserver                = $monit::params::mailserver,
  $mailformat                = $monit::params::mailformat,
  $alert_emails              = $monit::params::alert_emails,
  $start_delay               = $monit::params::start_delay,
  $mmonit_address            = $monit::params::mmonit_address,
  $mmonit_port               = $monit::params::mmonit_port,
  $mmonit_user               = $monit::params::mmonit_user,
  $mmonit_password           = $monit::params::mmonit_password,
  $mmonit_without_credential = $monit::params::mmonit_without_credential,
) inherits monit::params {
  # <stringified variable handling>
  if is_string($httpd) == true {
    $httpd_bool = str2bool($httpd)
  } else {
    $httpd_bool = $httpd
  }

  if is_string($manage_firewall) == true {
    $manage_firewall_bool = str2bool($manage_firewall)
  } else {
    $manage_firewall_bool = $manage_firewall
  }

  if is_string($service_enable) == true {
    $service_enable_bool = str2bool($service_enable)
  } else {
    $service_enable_bool = $service_enable
  }

  if is_string($service_manage) == true {
    $service_manage_bool = str2bool($service_manage)
  } else {
    $service_manage_bool = $service_manage
  }

  if is_string($mmonit_without_credential) == true {
    $mmonit_without_credential_bool = str2bool($mmonit_without_credential)
  } else {
    $mmonit_without_credential_bool = $mmonit_without_credential
  }

  if is_string($config_dir_purge) == true {
    $config_dir_purge_bool = str2bool($config_dir_purge)
  } else {
    $config_dir_purge_bool = $config_dir_purge
  }
  # </stringified variable handling>

  # <variable validations>
  validate_integer($check_interval, '', 0)
  validate_bool($httpd_bool)
  validate_integer($httpd_port, 65535, 0)
  validate_string($httpd_address)
  validate_string($httpd_user)
  validate_string($httpd_password)
  validate_bool($manage_firewall_bool)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_bool($service_enable_bool)
  validate_string($service_ensure)
  validate_bool($service_manage_bool)
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
  validate_integer($start_delay, '', 0)

  if $mmonit_address != undef {
    validate_string($mmonit_address)
  }

  validate_string($mmonit_port)
  validate_string($mmonit_user)
  validate_string($mmonit_password)
  validate_bool($mmonit_without_credential_bool)
  validate_absolute_path($config_file)
  validate_absolute_path($config_dir)
  validate_bool($config_dir_purge_bool)
  # </variable validations>

  # Use the monit_version fact if available, else use the default for the
  # platform.
  if defined('$::monit_version') and $::monit_version {
    $monit_version_real = $::monit_version
  } else {
    $monit_version_real = $monit::params::monit_version
  }

  if($start_delay + 0 > 0 and versioncmp($monit_version_real,'5') < 0) {
    fail("start_delay requires at least Monit 5.0. Detected version is <${monit_version_real}>.")
  }

  anchor { "${module_name}::begin": } ->
  class { "${module_name}::install": } ->
  class { "${module_name}::config": } ~>
  class { "${module_name}::service": } ->
  class { "${module_name}::firewall": }->
  anchor { "${module_name}::end": }
}
