## 2015-08-06 - Release 1.0.0
### Summary
This release updates metadata to support new version of RedHat family OSes, as well as new features and test improvements.

#### Features
- Added support to RedHat family OSes version 7.
- Added configuration option to set an M/Monit report server in Monit config file.
- Added support for start delay parameter.
- Added configuration option to set an M/Monit report server in Monit configuration file.
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
