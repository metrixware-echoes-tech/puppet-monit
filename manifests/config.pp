# Private class
class monit::config inherits monit {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $config_path:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template('monit/monitrc.erb'),
  }
}
