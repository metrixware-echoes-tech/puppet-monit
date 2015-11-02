include ::monit

monit::check { 'fake':
  content => 'fake content for the fake service check',
}
