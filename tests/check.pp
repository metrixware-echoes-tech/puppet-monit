include monit

monit::check { 'ntp':
  source => "puppet:///modules/${module_name}/ntp",
}
