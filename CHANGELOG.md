## 2016-11-07 - Release 1.1.2
### Summary
This release adds support to Ubuntu Xenial and improves compatibility with Puppet Server.

#### Features
- Added support to Ubuntu 16.04.

### Bugfixes
- Fixed condition that fails with `strict_variables` enabled on the Puppet Server side.

## 2016-08-30 - Release 1.1.1
### Summary
This release fixes typo and a bad URL. It is published with [Geppeto](https://puppetlabs.github.io/geppetto/).

## 2016-08-05 - Release 1.1.0
### Summary
This release adds support to Debian jessie, OracleLinux and Scientific OSes, as well as a `config_dir_purge` parameter and a lot of great test improvements.

#### Features
- Added support to Debian jessie.
- Added support to OracleLinux and Scientific.
- Added `monit_version` fact.
- Added `config_dir_purge` parameter to `monit` class and to the template of configuration file.

#### Bugfixes
- Fixed bad dependencies (puppetlabs/stdlib >= 4.6.0 + add puppetlabs/firewall)

#### Tests
- Amazing enhancement of code coverage (special thanks to [Phil Friderici](https://github.com/Phil-Friderici) and [Garrett Honeycutt](https://github.com/ghoneycutt))
- Puppet v3 (optionally with future parser) and v4 with Ruby versions 1.8.7 (Puppet v3 only), 1.9.3, 2.0.0 and 2.1.0.
- Improvment of style and additional community style checks

## 2015-08-06 - Release 1.0.0
### Summary
This release updates metadata to support new version of RedHat family OSes, as well as new features and test improvements.

#### Features
- Added support to RedHat family OSes version 7.
- Added configuration option to set an M/Monit report server in Monit configuration file.
- Added support for start delay parameter.
- Made HTTPd authentication by user and password optional.

#### Tests
- Added future parser in Travis matrix.
- Added acceptance tests.

##2015-06-06 - Release 0.5.0
###Summary
This release adds `mail-format` and `alert` parameters to the monit configuration file.

####Features
- Add `mailformat` parameter to `monit` class and to the template of configuration file.
- Add `alert_emails` parameter to `monit` class and to the template of configuration file.

####Bugfixes
- `ìdfile` parameter does not exist for Monit 4

##2015-04-02 - Release 0.4.0
###Summary
This release adds `logile` and `mailserver` parameters to the monit configuration file.

####Features
- Add `logfile` parameter to `monit` class and to the template of configuration file.
- Add `mailserver` parameter to `monit` class and to the template of configuration file.

####Bugfixes
- Bad variable use for configuration directory in `monit::check`

##2015-04-01 - Release 0.3.0
###Summary

This release adds support for RedHat family OSes.

##2015-02-22 - Release 0.2.0
###Summary

This release adds `content` parameter to `monit::check`.

##2015-02-09 - Release 0.1.4
###Summary

This release improves the compliance with Debian Squeeze and Ubuntu Lucid.

##2014-12-22 - Release 0.1.3
###Summary

This release adds tests and improves the compliance with Puppet Guidelines.

##0.1.2

2014-09-18

* Add parameter `ensure` for `monit::check` - wild <wild@portal>
* Fix bad validation for package_name for `monit::check` - Florent Poinsaut <florent.poinsaut@echoes-tech.com>

##0.1.1
2014-09-15 Florent Poinsaut <florent.poinsaut@echoes-tech.com>
* Typo

2014-09-03 https://github.com/wild-r
* Disable validate_absolute_path on check.pp to allow link like 'puppet://...'

##0.1.0
2014-08-29 Florent Poinsaut <florent.poinsaut@echoes-tech.com>
* Initial release
