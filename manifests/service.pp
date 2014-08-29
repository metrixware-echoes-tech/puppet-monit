# Private class
class monit::service inherits monit {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $monit::service_manage {
    if ($::osfamily == 'Debian') {
      file { '/etc/default/monit':
        content => 'START=yes',
        before  => Service['monit'],
      }
    }

    service { 'monit':
      ensure     => $monit::service_ensure,
      enable     => $monit::service_enable,
      name       => $monit::service_name,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
