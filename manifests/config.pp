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

  file { $monit::config_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => $monit::config_dir_purge_bool,
    recurse => $monit::config_dir_purge_bool,
    require => Package[$monit::package_name],
  }

  file { $monit::config_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('monit/monitrc.erb'),
    require => Package[$monit::package_name],
  }
}
