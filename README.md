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
    - [Using Plans](#using-plans)
    - [Using Idempotent Puppet Resource Types](#using-idempotent-puppet-resource-types)
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
    - name: my_array
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

Every PowerStore API endpoint has a corresponding task. For example, for manipulating PowerStore volumes, the following tasks are available:
- volume_collection_query
- volume_instance_query
- volume_attach
- volume_clone
- volume_create
- volume_delete
- volume_detach
- volume_modify
- volume_refresh
- volume_restore
- volume_snapshot

Task usage is displayed by running `bolt task show`, for example:

```
bolt task show powerstore::volume_attach

powerstore::volume_attach - Attach a volume to a host or host group.

USAGE:
bolt task run --targets <node-name> powerstore::volume_attach host_group_id=<value> host_id=<value> id=<value> logical_unit_number=<value>

PARAMETERS:
- host_group_id: Optional[String]
    Unique identifier of the host group to be attached to the volume. Only one of host_id or host_group_id can be supplied.
- host_id: Optional[String]
    Unique identifier of the host to be attached to the volume. Only one of host_id or host_group_id can be supplied.
- id: String
    Unique identifier of volume to attach.
- logical_unit_number: Optional[Integer[0,16383]]
    Logical unit number for the host volume access.
```

The --targets parameter is the name of the device as configured in the inventory file (see above).

Every parameter is displayed along with its data type. Optional parameters have a type starting with the word `Optional`. So in the above example, the task accepts 3 parameters:
- `host_group_id`: optional String parameter
- `host_id`: optional String parameter
- `id`: required String parameter
- `logical_unit_number`: optional parameter, should be an Integer between 0 and 16383.

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

### Using Plans

Puppet Plans are higher-level workflows which can leverage logic, tasks and commands to perform orchestrated operations on managed devices. Puppet Plans can be written using YAML or Puppet language. Example plans can be found in the [plans](plans) directory and are documented [here](REFERENCE.md#plans).

For displaying usage information for a plan, run `bolt plan show`. for example:
```
> bolt plan show powerstore::capacity_volumes

powerstore::capacity_volumes - list volumes with more than given capacity

USAGE:
bolt plan run powerstore::capacity_volumes threshold=<value> targets=<value>

PARAMETERS:
- threshold: Variant[Numeric,String]
    Volume capacity needed (in bytes or MB/GB/TB)
- targets: TargetSpec
```

Example of running the plan:

```
> bolt plan run powerstore::capacity_volumes -t pws3k threshold=220G
Starting: plan powerstore::capacity_volumes
Starting: task powerstore::volume_collection_query on my_array
Finished: task powerstore::volume_collection_query with 0 failures in 1.64 sec
+----------------------+-----------------+------------+
|        List of volumes with capacity > 220G         |
+----------------------+-----------------+------------+
| volume name          | capacity        | MB         |
+----------------------+-----------------+------------+
| Volume1              |  43980465111040 |   43.98 TB |
| my_large_volume      |    595926712320 |  595.93 GB |
| my_terabyte_volume   |   1099511627776 |    1.10 TB |
+----------------------+-----------------+------------+
Finished: plan powerstore::capacity_volumes in 1.94 sec
Plan completed successfully with no result
```

### Using Idempotent Puppet Resource Types

Tasks are an imperative way to query or manipulate state. In addition, the `powerstore` module offers Puppet types which offer an idempotent way of managing the devices's desired state.

Example of managing a volume called `my_volume` and ensuring it is created if it does not exist:

1. Example using YAML-language plan:
    ```yaml
        resources:
          - powerstore_volume: my_volume
            parameters:
              size: 26843545600
              description: My 25G Volume
              ensure: present
    ```
1. Example using a Puppet-language plan:
    ```puppet
          powerstore_volume { 'my_volume':
            ensure      => present,
            size        => 26843545600,
            description => 'My 25G Volume',
          }
    ```

See the [create_volume.pp](plans/create_volume.pp) and [create_volume_yaml.yaml](plans/create_volume_yaml.yaml) example plans showing a parametrized version of the above.

See the reference documentation for a list of all available [Resource types](REFERENCE.md#resource-types).

## Reference

Please see [REFERENCE](REFERENCE.md) for detailed information on available resource types, tasks and plans.

Direct links to the various parts of the reference documentation:

1. [Plans](REFERENCE.md#plans)
1. [Tasks](REFERENCE.md#tasks)
1. [Resource types](REFERENCE.md#resource-types)
1. [Functions](REFERENCE.md#functions)

## Limitations

... forthcoming ...

## Development

... forthcoming ...

## Contributors


## Contact

... forthcoming ...

## Release Notes

- 0.1.0
  * Initial release