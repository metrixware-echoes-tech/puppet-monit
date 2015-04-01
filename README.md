# monit

[![Build Status](https://travis-ci.org/echoes-tech/puppet-monit.svg?branch=master)](https://travis-ci.org/echoes-tech/puppet-monit)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with monit](#setup)
    * [Beginning with monit](#beginning-with-monit)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Enable Monit Dashboard](#enable-monit-dashboard)
    * [Add a check](#add-a-check)
    * [Remove a check](#remove-a-check)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributors](#contributors)

## Overview

Puppet module to manage Monit installation and configuration.


## Module Description

This module installs and configures [Monit](http://mmonit.com/monit/).
It allows you to enable HTTP Dashboard an to add check from a file.

## Setup

### Beginning with monit

```puppet
include 'monit'
```

**WARNING:** For RedHat systems, you may need to add an additional repository like the [EPEL repository](http://fedoraproject.org/wiki/EPEL).
You can use the module [stahnma-epel](https://forge.puppetlabs.com/stahnma/epel) to do this.

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

## Limitations

RedHat and Debian family OSes are officially supported. Tested and built on Debian and CentOS.

## Contributors

The list of contributors can be found at: https://github.com/echoes-tech/puppet-monit/graphs/contributors
