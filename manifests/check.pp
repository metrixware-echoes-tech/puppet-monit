define monit::check (
  $ensure       = present,
  $source       = undef,
  $content      = undef,
  $package_name = 'monit',
  $service_name = 'monit',
) {
  validate_re (
    $ensure,
    '^(present|absent)$',
    "${ensure} is not supported for ensure. \
Allowed values are 'present' and 'absent'."
  )
  validate_string($package_name)
  validate_string($service_name)

  if $source and $content {
    fail 'Parameters source and content are mutually exclusive'
  }
  if $source {
    validate_string($source)
  }
  if $content {
    validate_string($content)
  }

  include monit::params

  file { "${monit::config_dir}/${name}":
    ensure  => $ensure,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    source  => $source,
    content => $content,
    notify  => Service[$service_name],
    require => Package[$package_name],
  }
}
