class monit::params {
  $check_interval  = 120
  $httpd           = false
  $httpd_port      = 2812
  $httpd_address   = 'localhost'
  $httpd_user      = 'admin'
  $httpd_password  = 'monit'
  $manage_firewall = true
  $package_ensure  = 'present'
  $package_name    = 'monit'
  $service_enable  = true
  $service_ensure  = 'running'
  $service_manage  = true
  $service_name    = 'monit'

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
    }
    default: {
      fail("Unsupported OS family: ${::osfamily}")
    }
  }
}
