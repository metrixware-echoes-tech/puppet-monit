# Private class
class monit::service inherits monit {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $monit::service_manage {
    if ($::osfamily == 'Debian') {
      $content = $::lsbdistcodename ? {
        'squeeze' => 'startup=1',
        default   => 'START=yes',
      }
      file { '/etc/default/monit':
        content => $content,
        before  => Service['monit'],
      }
    }

    $hasstatus = $::lsbdistcodename ? {
      'squeeze' => false,
      default   => true,
    }

    service { 'monit':
      ensure     => $monit::service_ensure,
      enable     => $monit::service_enable,
      name       => $monit::service_name,
      hasrestart => true,
      hasstatus  => $hasstatus,
    }
  }
}
