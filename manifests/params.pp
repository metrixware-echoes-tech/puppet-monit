# == Class: monit::params
#
# This is a container class with default parameters for monit classes.
class monit::params {
  $check_interval            = 120
  $config_dir_purge          = false
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

  # <OS family handling>
  case $::osfamily {
    'Debian': {
      $config_file   = '/etc/monit/monitrc'
      $config_dir    = '/etc/monit/conf.d'
      $monit_version = '5'

      case $::lsbdistcodename {
        'squeeze', 'lucid': {
          $default_file_content = 'startup=1'
          $service_hasstatus    = false
        }
        'wheezy', 'jessie', 'stretch', 'precise', 'trusty', 'xenial': {
          $default_file_content = 'START=yes'
          $service_hasstatus    = true
        }
        default: {
          fail("monit supports Debian 6 (squeeze), 7 (wheezy), 8 (jessie) and 9 (stretch) \
and Ubuntu 10.04 (lucid), 12.04 (precise), 14.04 (trusty) and 16.04 (xenial). \
Detected lsbdistcodename is <${::lsbdistcodename}>.")
        }

      }
    }
    'RedHat': {
      $config_dir        = '/etc/monit.d'
      $service_hasstatus = true

      case $::operatingsystemmajrelease {
        '5': {
          $monit_version = '4'
          $config_file   = '/etc/monit.conf'
        }
        '6': {
          $monit_version = '5'
          $config_file   = '/etc/monit.conf'
        }
        '7': {
          $monit_version = '5'
          $config_file   = '/etc/monitrc'
        }
        default: {
          fail("monit supports EL 5, 6 and 7. Detected operatingsystemmajrelease is <${::operatingsystemmajrelease}>.")
        }
      }
    }
    default: {
      fail("monit supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
  }
  # </OS family handling>
}
