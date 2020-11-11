# Puppet module for a PowerStore Storage Appliance

#### Table of Contents

- [Puppet module for a PowerStore Storage Appliance](#puppet-module-for-a-powerstore-storage-appliance)
      - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [License](#license)
  - [Setup](#setup)
    - [Requirements](#requirements)
    - [Installation](#installation)
  - [Usage](#usage)
    - [Using Tasks](#using-tasks)
      - [Introduction to PowerStore tasks](#introduction-to-powerstore-tasks)
      - [Examples](#examples)
  - [Reference](#reference)
  - [Limitations](#limitations)
  - [Development](#development)
  - [Contributors](#contributors)
  - [Contact](#contact)
  - [Release Notes](#release-notes)

## Overview

The `dellemc-powerstore` module manages resources on a Dell EMC PowerStore Storage Appliance.

Dell EMC PowerStore is a next-generation midrange data storage solution targeted at customers who are looking for value, flexibility, and simplicity. PowerStore provides our customers with data-centric, intelligent, and adaptable infrastructure that supports both traditional and modern workloads.

The `dellemc-powerstore` Puppet module allows you to configure and deploy the PowerStore appliance using Puppet Bolt. To that end it offers types and providers, tasks and plans.

## License

[Apache License version 2](LICENSE)

## Setup

### Requirements

 * Puppet Bolt `2.29.0` or later

### Installation

1. Follow [instructions for installing Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html).

1. Create a Bolt project with a name of your choosing, for example:
    ```bash
    mkdir pws
    cd pws
    bolt project init --modules dellemc-powerstore
    ```
    Your new Bolt project is ready to go. To list available plans, run
    ```bash
    bolt plan show
    ```
    To list all Bolt tasks related to the `volume` resource, run
    ```bash
    bolt task show --filter volume
    ```
    See [Bolt documentation](https://puppet.com/docs/bolt/latest/bolt.html) for more information on Puppet Bolt.

1. Create an `inventory.yaml` in your project directory, like so:
   ```yaml
    version: 2
    targets:
    - uri: 127.0.0.1
      name: my_array
      config:
        transport: remote
        remote:
          host: my.powerstore.host
          user: admin
          password: My$ecret!
          remote-transport: powerstore
   ``` 
## Usage

### Using Tasks

#### Introduction to PowerStore tasks

Every PowerStore API endpoint has a corresponding task. For example, for manilupating PowerStore volumes, the following tasks are available:
- volume_attach
- volume_clone
- volume_collection_query
- volume_create
- volume_delete
- volume_detach
- volume_instance_query
- volume_modify
- volume_refresh
- volume_restore
- volume_snapshot

#### Examples

- Get a list of volumes:
  
  ```bash
  bolt task run powerstore::volume_collection_query -t my_array
  ```

- Get details of one volume:
  
  ```bash
  bolt task run powerstore::volume_instance_query id=<volume_id> -t my_array
  ```

- Create a volume:
  
  ```bash
  bolt task run powerstore::volume_create name="small_volume" size=1048576 description="Small Volume" -t my_array
  ```

* Define a managed Unity system

```puppet
unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
  ensure => present,
}
```

The defined system `Unity_system['FNM12345678901']` then can be passed to any Unity resources.


* Upload a license

```puppet
unity_license { '/path/to/the/license.lic':
  unity_system => Unity_system['FNM12345678901'],
  ensure => present,
}
```

Note: the path separator in the `title` must be `/` even using on Windows agent.
* Create a pool

```puppet
unity_pool { 'puppet_pool':
  unity_system => Unity_system['FNM12345678901'],
  description => 'created by puppet module',
  raid_groups => [{
    disk_group => 'dg_15',
    raid_type => 1,
    stripe_width => 0,
    disk_num => 5,
  }],
  ensure => present,
}
```

* Create a iSCSI portal on ethernet port

```puppet
unity_iscsi_portal { '10.244.213.245':
  unity_system  => Unity_system['FNM12345678901'],
  ethernet_port => 'spa_eth3',
  netmask       => '255.255.255.0',
  vlan          => 133,
  gateway       => '10.244.213.1',
  ensure        => present,
}
```

* Create a Host

```puppet
unity_host { 'my_host':
  unity_system => Unity_system['FNM12345678901'],
  description  => 'Created by puppet',
  ip           => '192.168.1.139',
  os           => 'Ubuntu16',
  host_type    => 1,
  iqn          => 'iqn.1993-08.org.debian:01:unity-puppet-host',
  wwns         => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D3',
     '20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D4'],
  ensure       => present,
}
```

* Create a io limit policy

```puppet
# Create a Unity io limit policy (absolute limit)
unity_io_limit_policy { 'puppet_policy':
  unity_system => Unity_system['FNM12345678901'],
  policy_type => 1,
  description => 'Created by puppet 12',
  max_iops => 1000,
  max_kbps => 20480,
  burst_rate => 50,
  burst_time => 10,
  burst_frequency => 2,
}
```

The meaning for above burst settings is: **50% for 10 minute(s) resetting every 2 hour(s)**.

* Create a LUN

```puppet
unity_lun { 'puppet_lun':
  unity_system    => Unity_system['FNM12345678901'],
  pool            => Unity_pool['puppet_pool'],
  size            => 15,
  thin            => true,
  compression     => false,
  sp              => 0,
  description     => "Created by puppet_unity.",
  io_limit_policy => Unity_io_limit_policy['puppet_policy'],
  hosts           => [Unity_host['my_host']],
  ensure          => present,
}
```

* Define multiple Unity system in manifest file

Administrator can define multiple systems and manage the resources on systems via a single manifest file.

Please refer to the example file here: [example_multiple_systems](examples/example_multiple_systems.pp)


## Reference

Please see [REFERENCE](REFERENCE.md) for detailed information on available resource types, tasks and plans.

## Limitations


## Development

Simply fork the repo and send PR for your code change(also provide testing result of your change), remember to give a title and description of your PR.

## Contributors

## Contact

## Release Notes

- 0.1.0
    * Initial release.