include monit

monit::check { 'ntp':
  source => "puppet:///modules/${module_name}/ntp",
}

monit::check { 'fake':
  content => 'fake content for the fake service check',
}
