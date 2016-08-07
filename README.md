# monit

This is a fork of [echoes/monit](https://github.com/echoes-tech/puppet-monit).

This module has been heavily refactored and extensive spec tests were added.
Version 1.0.0 of this module is compatible with v1.0.0 of echoes/monit, so you
can swap modules without worry.


#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with monit](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with monit](#beginning-with-monit)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Enable Monit Dashboard](#enable-monit-dashboard)
    * [Add a check](#add-a-check)
    * [Remove a check](#remove-a-check)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Contributors](#contributors)

## Overview

Puppet module to manage Monit installation and configuration.


## Module Description

This module installs and configures [Monit](http://mmonit.com/monit/).
It allows you to enable HTTP Dashboard an to add check from a file.

## Setup

### Setup Requirements

**WARNING:** For RedHat systems, you may need to add an additional repository like the [EPEL repository](http://fedoraproject.org/wiki/EPEL).
You can use the module [stahnma-epel](https://forge.puppetlabs.com/stahnma/epel) to do this.

Supports Puppet v3 (optionally with future parser) and v4 with Ruby versions
1.8.7 (Puppet v3 only), 1.9.3, 2.0.0 and 2.1.0.

### Beginning with monit

```puppet
include ::monit
```

## Usage

### Enable Monit Dashboard

```puppet
class { 'monit':
  httpd          => true,
  httpd_address  => '172.16.0.3',
  httpd_password => 'CHANGE_ME',
}
```

### Add a check

Using the source parameter:

```puppet
monit::check { 'ntp':
  source => "puppet:///modules/${module_name}/ntp",
}
```

Or using the content parameter with a string:

```puppet
monit::check { 'ntp':
  content => 'check process ntpd with pidfile /var/run/ntpd.pid
  start program = "/etc/init.d/ntpd start"
  stop  program = "/etc/init.d/ntpd stop"
  if failed host 127.0.0.1 port 123 type udp then alert
  if 5 restarts within 5 cycles then timeout
',
}
```

Or using the content parameter with a template:

```puppet
monit::check { 'ntp':
  content => template("${module_name}/ntp.erb"),
}
```

### Remove a check

```puppet
monit::check { 'ntp':
  ensure => absent,
}
```

## Reference

### Classes

#### Public classes

* monit: Main class.

#### Parameters

The following parameters are available in the `::monit` class:

##### `alert_emails`

Specifies one or more email addresses to send global alerts to. Valid options: array. Default value: []

##### `check_interval`

Specifies the interval between two checks of Monit. Valid options: numeric. Default value: 120

##### `config_file`

Specifies a path to the main config file. Valid options: string. 'USE_DEFAULTS' will choose the options based on the operating system. Default value: 'USE_DEFAULTS'

##### `config_dir`

Specifies a path to the config directory. Valid options: string. 'USE_DEFAULTS' will choose the options based on the operating system. Default value: 'USE_DEFAULTS'

##### `config_dir_purge`

Specifies if unmanaged files in the config directory should be purged. Valid options: 'true' or 'false'. Default value: 'false'

##### `httpd`

Specifies whether to enable the Monit Dashboard. Valid options: 'true' or 'false'. Default value: 'false'

##### `httpd_port`

Specifies the port of the Monit Dashboard. Valid options: numeric. Default value: 2812

##### `httpd_address`

Specifies the IP address of the Monit Dashboard. Valid options: string. Default value: 'locahost'

##### `httpd_user`

Specifies the user to access the Monit Dashboard. Valid options: string. Default value: 'admin'

##### `httpd_password`

Specifies the password to access the Monit Dashboard. Valid options: string. Default value: 'monit'

##### `logfile`

Specifies the logfile directive value. Valid options: string. Default value: '/var/log/monit.log'

Set to eg 'syslog facility log_daemon' to use syslog instead of direct file logging.

##### `mailserver`

If set to a string, alerts will be sent by email to this mailserver. Valid options: string. Default value: undef

For more details, see: https://mmonit.com/monit/documentation/monit.html#Setting-a-mail-server-for-alert-delivery

##### `mailformat`

Specifies the alert message format. Valid options: hash. Default value: undef

For more details, see: https://mmonit.com/monit/documentation/monit.html#Message-format

##### `manage_firewall`

If true and if puppetlabs-firewall module is present, Puppet manages firewall to allow HTTP access for Monit Dashboard. Valid options: 'true' or 'false'. Default value: 'false'

##### `mmonit_address` *Requires at least Monit 5.0*

Specifies the remote address of an M/Monit server to be used by Monit agent for report. If set to undef, M/Monit connection is disabled. Valid options: string. Default value: undef

##### `mmonit_port` *Requires at least Monit 5.0*

Specifies the remote port of the M/Monit server. Valid options: numeric. Default value: 8080

##### `mmonit_user` *Requires at least Monit 5.0*

Specifies the user to connect to the remote M/Monit server. Valid options: string. Default value: 'monit'

If you set both user and password to an empty string, authentication is disabled.

##### `mmonit_password` *Requires at least Monit 5.0*

Specifies the password of the account used to connect to the remote M/Monit server. Valid options: string. Default value: 'monit'

If you set both user and password to an empty string, authentication is disabled.

##### `mmonit_without_credential` *Requires at least Monit 5.0*

By default Monit registers credentials with M/Monit so M/Monit can smoothly communicate back to Monit and you don't have to register Monit credentials manually in M/Monit. It is possible to disable credential registration setting this option to 'true'. Valid options: 'true' or 'false'. Default value: 'false'

##### `package_ensure`

Tells Puppet whether the Monit package should be installed, and what version. Valid options: 'present', 'latest', or a specific version number. Default value: 'present'

##### `package_name`

Tells Puppet what Monit package to manage. Valid options: string. Default value: 'monit'

##### `service_ensure`

Tells Puppet whether the Monit service should be running. Valid options: 'running' or 'stopped'. Default value: 'running'

##### `service_manage`

Tells Puppet whether to manage the Monit service. Valid options: 'true' or 'false'. Default value: 'true'

##### `service_name`

Tells Puppet what Monit service to manage. Valid options: string. Default value: 'monit'

##### `start_delay` *Requires at least Monit 5.0*

If set, Monit will wait the specified time in seconds before it starts checking services. Valid options: numeric. Default value: 0

### Defines

#### Public defines

* monit::check: Adds a Monit check.

#### Parameters

The following parameters are available in the `::monit::check` define:

##### `ensure`

Tells Puppet whether the check should exist. Valid options: 'present', 'absent'. Default value: present

##### `source`

Tells Puppet what is the path of the configuration file. Valid options: string. Exclusive with the `content` parameter. Default value: undef

##### `content`

Specifies the content of the configuration file. Valid options: string. Exclusive with the `source` parameter. Default value: undef

##### `package_name`

Tells Puppet which Monit package is required. Valid options: string. Default value: 'monit'

##### `service_name`

Tells Puppet which Monit service will be notify. Valid options: string. Default value: 'monit'

## Limitations

RedHat and Debian family OSes are officially supported. Tested and built on Debian and CentOS.

##Development

[Fork this module on GitHub](https://github.com/ghoneycutt/puppet-module-monit/fork)

## Contributors

The list of contributors can be found at: https://github.com/ghoneycutt/puppet-module-monit/graphs/contributors
