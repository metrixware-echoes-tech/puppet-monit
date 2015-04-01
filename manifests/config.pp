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
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $monit::config_file:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template('monit/monitrc.erb'),
  }
}
