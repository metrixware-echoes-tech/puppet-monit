# Private class
class monit::config inherits monit {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/var/lib/monit':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { 'monit_config_dir':
    ensure  => directory,
    path    => $monit::config_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => $monit::config_dir_purge_bool,
    recurse => $monit::config_dir_purge_bool,
    require => Package['monit'],
  }

  file { 'monit_config':
    ensure  => file,
    path    => $monit::config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('monit/monitrc.erb'),
    require => Package['monit'],
  }
}
