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

```puppet
monit::check { 'ntp':
  source => "puppet:///modules/${module_name}/ntp",
}
```

### Remove a check

```puppet
monit::check { 'ntp':
  ensure => absent,
}
```

## Limitations

Debian family OSes are officially supported. Tested and built on Debian.

## Contributors

The list of contributors can be found at: https://github.com/echoes-tech/puppet-monit/graphs/contributors
