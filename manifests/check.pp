# == Define: monit::check
#
define monit::check (
  $content = undef,
  $ensure  = present,
  $source  = undef,
) {
  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['monit']) {
    fail('You must include the monit base class before using any monit defined resources')
  }

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

  file { "${::monit::config_dir}/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $source,
    content => $content,
    require => Package['monit'],
    notify  => Service['monit'],
  }
}
