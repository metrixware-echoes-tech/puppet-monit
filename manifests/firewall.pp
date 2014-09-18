# Private class
class monit::firewall {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $monit::httpd and $monit::manage_firewall {
    if defined('::firewall') {
      firewall { "${monit::httpd_port} allow Monit inbound traffic":
        action => 'accept',
        dport  => $monit::httpd_port,
        proto  => 'tcp',
      }
    }
  }
}
