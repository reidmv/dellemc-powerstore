require 'puppet/resource_api'

# rubocop:disable Style/StringLiterals
Puppet::ResourceApi.register_type(
  name: 'powerstore_host_group',
  features: ['remote_resource'],

  desc: <<-EOS,
    Manage host groups.
 A host group is a mechanism to provision hosts and volumes to be consistent across the Cyclone cluster. Operations that can be performed include, creating or deleting a host group, modifying host group(i.e. adding or removing hosts from a host group).
  EOS
  attributes:   {
    ensure:      {
      type:      "Enum['present', 'absent']",
      desc:      'Whether this resource should be present or absent on the target system.',
      default:   'present',
    },
    add_host_ids:          {
      type:      "Optional[Array[String]]",
      desc:      "List of hosts to be added to host group. The operation fails if the host(s) to be added are attached to volume.",
    },
    description:          {
      type:      "Optional[String[0,256]]",
      desc:      "An optional description for the host group. The description should not have any unprintable characters.",
    },
    host_ids:          {
      type:      "Optional[Array[String]]",
      desc:      "",
      behaviour: :init_only,
    },
    id:          {
      type:      "Optional[String]",
      desc:      "Unique id of the host group.",
      behaviour: :read_only,
    },
    name:          {
      type:      "String[0,128]",
      desc:      "The host group name. The name should not be more than 128 UTF-8 characters long and should not have any unprintable characters.",
      behaviour: :namevar,
    },
    remove_host_ids:          {
      type:      "Optional[Array[String]]",
      desc:      "List of hosts to be removed from the host group. The operation fails if host group is attached to volume.",
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
