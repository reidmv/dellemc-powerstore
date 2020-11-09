require 'puppet/resource_api'

# rubocop:disable Style/StringLiterals
Puppet::ResourceApi.register_type(
  name: 'powerstore_file_interface',
  features: ['remote_resource'],

  desc: <<-EOS,
    Information about File network interfaces in the storage system. These interfaces control access to Windows (CIFS) and UNIX/Linux (NFS) file storage.
  EOS
  attributes:   {
    ensure:      {
      type:      "Enum['present', 'absent']",
      desc:      'Whether this resource should be present or absent on the target system.',
      default:   'present',
    },
    gateway:          {
      type:      "Optional[String[1,45]]",
      desc:      "Gateway address for the network interface. IPv4 and IPv6 are supported.",
    },
    id:          {
      type:      "String",
      desc:      "Unique identifier of the file interface.",
      behaviour: :namevar,
    },
    ip_address:          {
      type:      "Optional[String[1,45]]",
      desc:      "IP address of the network interface. IPv4 and IPv6 are supported.",
    },
    is_disabled:          {
      type:      "Optional[Boolean]",
      desc:      "Indicates whether the network interface is disabled.",
    },
    name:          {
      type:      "Optional[String]",
      desc:      "Name of the network interface. This property supports case-insensitive filtering",
    },
    nas_server_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the NAS server to which the network interface belongs, as defined by the nas_server resource type.",
      behaviour: :init_only,
    },
    prefix_length:          {
      type:      "Optional[Integer[1,128]]",
      desc:      "Prefix length for the interface. IPv4 and IPv6 are supported.",
    },
    role:          {
      type:      "Optional[Enum['Production','Backup']]",
      desc:      "- Production - This type of network interface is used for all file protocols and services of a NAS server. This type of interface is inactive while a NAS server is in destination mode. - Backup  - This type of network interface is used only for NDMP/NFS backup or disaster recovery testing. This type of interface is always active in all NAS server modes.",
      behaviour: :init_only,
    },
    role_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to role",
    },
    vlan_id:          {
      type:      "Optional[Integer[0,4094]]",
      desc:      "Virtual Local Area Network (VLAN) identifier for the interface. The interface uses the identifier to accept packets that have matching VLAN tags.",
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
