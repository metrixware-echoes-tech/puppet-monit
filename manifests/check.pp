# == Define: monit::check
#
define monit::check (
  $ensure  = present,
  $source  = undef,
  $content = undef,
) {

  include ::monit

  validate_re($ensure, '^(present|absent)$',
    "monit::check::ensure is <${ensure}> and must be 'present' or 'absent'.")

  if $source and $content {
    fail 'Parameters source and content are mutually exclusive'
  }
  if $source {
    validate_string($source)
  }
  if $content {
    validate_string($content)
  }

  file { "${monit::config_dir}/${name}":
    ensure  => $ensure,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    source  => $source,
    content => $content,
    require => Package[$monit::package_name],
    notify  => Service[$monit::service_name],
  }
}
