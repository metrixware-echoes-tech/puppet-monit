# Private class
class monit::install inherits monit {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { $monit::package_name:
    ensure => $monit::package_ensure,
    alias  => 'monit',
  }
}
