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
  validate_string($config_file)
  validate_string($config_dir)
  validate_string($logfile)
  if $mailserver {
    validate_string($mailserver)
  }
  if $mailformat {
    validate_hash($mailformat)
  }
  validate_array($alert_emails)
  validate_integer($start_delay, undef, 0)
  if($start_delay > 0 and $::monit_version < '5') {
    fail('Monit option "start_delay" requires at least Monit 5.0"')
  }
  if $mmonit_address {
    validate_string($mmonit_address)
    validate_string($mmonit_port)
    validate_string($mmonit_user)
    validate_string($mmonit_password)
    validate_bool($mmonit_without_credential)
  }

  anchor { "${module_name}::begin": } ->
  class { "${module_name}::install": } ->
  class { "${module_name}::config": } ~>
  class { "${module_name}::service": } ->
  class { "${module_name}::firewall": }->
  anchor { "${module_name}::end": }
}
