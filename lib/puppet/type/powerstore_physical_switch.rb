require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'powerstore_physical_switch',
  features: [ 'remote_resource' ],

  desc: <<-EOS,
    
  EOS
  attributes:   {
    ensure:      {
      type: "Enum['present', 'absent']",
      desc: "Whether this resource should be present or absent on the target system.",
      default: "present",
    },

    connections:          {
      type:      "Array[Struct[{Optional[ssh_password] => String, Optional[username] => String, address => String[1,255], connect_method => Enum['SSH','SNMPv2c'], Optional[port] => Integer[0,65535], Optional[snmp_community_string] => String, }]]",
      desc:      "Supported connections for a physical switch.",
    },
    id:          {
      type:      "String",
      desc:      "Unique identifier of the physical switch settings.",
    },
    name:          {
      type:      "String[1,128]",
      desc:      "Name of a physical switch.",
      behaviour: :namevar,
    },
    purpose:          {
      type:      "Enum['Data_and_Management','Management_Only']",
      desc:      "Physical switch purpose in network. Possible purposes are:  * Data_and_Management - Physical switch for all data and management networks.  * Management_Only - Physical switch for management network only.",
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
