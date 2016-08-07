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

  if $source != undef and is_string($source) == false {
    fail 'monit::check::source is not a string.'
  }
  if $content != undef and is_string($content) == false {
    fail 'monit::check::content is not a string.'
  }

  file { "${monit::config_dir_real}/${name}":
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
