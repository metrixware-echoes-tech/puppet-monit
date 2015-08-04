# == Class: monit::params
#
# This is a container class with default parameters for monit classes.
class monit::params {
  $check_interval            = 120
  $httpd                     = false
  $httpd_port                = 2812
  $httpd_address             = 'localhost'
  $httpd_user                = 'admin'
  $httpd_password            = 'monit'
  $manage_firewall           = false
  $package_ensure            = 'present'
  $package_name              = 'monit'
  $service_enable            = true
  $service_ensure            = 'running'
  $service_manage            = true
  $service_name              = 'monit'
  $logfile                   = '/var/log/monit.log'
  $mailserver                = undef
  $mailformat                = undef
  $alert_emails              = []
  $start_delay               = 0
  $mmonit_address            = undef
  $mmonit_port               = '8080'
  $mmonit_user               = 'monit'
  $mmonit_password           = 'monit'
  $mmonit_without_credential = false

  case $::osfamily {
    'Debian': {
      case $::lsbdistcodename {
        'squeeze', 'lucid': {
          $default_file_content = 'startup=1'
          $service_hasstatus    = false
        }
        default: {
          $default_file_content = 'START=yes'
          $service_hasstatus    = true
        }
      }
      $monit_version = '5'
      $config_file = '/etc/monit/monitrc'
      $config_dir  = '/etc/monit/conf.d'
    }
    'RedHat': {
      if versioncmp($::operatingsystemrelease, '6') < 0 {
        $monit_version = '4'
      } else {
        $monit_version = '5'
      }
      $service_hasstatus = true
      $config_dir        = '/etc/monit.d'

      if versioncmp($::operatingsystemrelease, '7') < 0 {
        $config_file = '/etc/monit.conf'
      } else {
        $config_file = '/etc/monitrc'
      }


    }
    default: {
      fail("Unsupported OS family: ${::osfamily}")
    }
  }
}
