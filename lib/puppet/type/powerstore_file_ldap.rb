require 'puppet/resource_api'

# rubocop:disable Style/StringLiterals
Puppet::ResourceApi.register_type(
  name: 'powerstore_file_ldap',
  features: ['remote_resource'],

  desc: <<-EOS,
    Use these resources to manage the Lightweight Directory Access Protocol (LDAP) settings for the NAS Server. You can configure one LDAP settings object per NAS Server. LDAP is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. A NAS Server can use LDAP as a Unix Directory Service to map users, retrieve netgroups, and build a Unix credential. When an initial LDAP configuration is applied, the system checks for the type of LDAP server. It can be an Active Directory schema or an RFC 2307 schema.
  EOS
  attributes:   {
    ensure:      {
      type:      "Enum['present', 'absent']",
      desc:      'Whether this resource should be present or absent on the target system.',
      default:   'present',
    },
    add_addresses:          {
      type:      "Optional[Array[String]]",
      desc:      "IP addresses to add to the current server IP addresses list. The addresses may be IPv4 or IPv6. Error occurs if an IP address already exists in the addresses list. Cannot be combined with addresses.",
    },
    addresses:          {
      type:      "Optional[Array[String]]",
      desc:      "The list of LDAP server IP addresses. The addresses may be IPv4 or IPv6.",
    },
    authentication_type:          {
      type:      "Optional[Enum['Anonymous','Simple','Kerberos']]",
      desc:      "Authentication type for the LDAP server.* Anonymous - Anonymous authentication means no authentication occurs and the NAS Server uses an anonymous login to access the LDAP-based directory server.* Simple - Simple authentication means the NAS Server must provide a bind distinguished name and password to access the LDAP-based directory server.* Kerberos - Kerberos authentication means the NAS Server uses a KDC to confirm the identity when accessing the Active Directory.",
    },
    authentication_type_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to authentication_type",
    },
    base_dn:          {
      type:      "Optional[String[3,255]]",
      desc:      "Name of the LDAP base DN. Base Distinguished Name (BDN) of the root of the LDAP directory tree. The appliance uses the DN to bind to the LDAP service and locate in the LDAP directory tree to begin a search for information.  The base DN can be expressed as a fully-qualified domain name or in X.509 format by using the attribute dc=. For example, if the fully-qualified domain name is mycompany.com, the base DN is expressed as dc=mycompany,dc=com.",
    },
    bind_dn:          {
      type:      "Optional[String[0,1023]]",
      desc:      "Bind Distinguished Name (DN) to be used when binding.",
    },
    bind_password:          {
      type:      "Optional[String[0,1023]]",
      desc:      "The associated password to be used when binding to the server.",
    },
    id:          {
      type:      "String",
      desc:      "LDAP settings object Id.",
      behaviour: :namevar,
    },
    is_certificate_uploaded:          {
      type:      "Optional[Boolean]",
      desc:      "Indicates whether an LDAP certificate file has been uploaded.",
    },
    is_config_file_uploaded:          {
      type:      "Optional[Boolean]",
      desc:      "Indicates whether an LDAP configuration file has been uploaded.",
    },
    is_smb_account_used:          {
      type:      "Optional[Boolean]",
      desc:      "Indicates whether SMB authentication is used to authenticate to the LDAP server. Values are:     * true - Indicates that the SMB settings are used for Kerberos authentication.    * false - Indicates that Kerberos uses its own settings.",
    },
    is_verify_server_certificate:          {
      type:      "Optional[Boolean]",
      desc:      "Indicates whether Certification Authority certificate is used to verify the LDAP server certificate for secure SSL connections. Values are: * true - verifies LDAP server's certificate. * false - doesn't verify LDAP server's certificate.",
    },
    nas_server_id:          {
      type:      "Optional[String]",
      desc:      "Unique identifier of the associated NAS Server instance that will use this LDAP object. Only one LDAP object per NAS Server is supported.",
      behaviour: :init_only,
    },
    password:          {
      type:      "Optional[String[0,1023]]",
      desc:      "The associated password for Kerberos authentication.",
    },
    port_number:          {
      type:      "Optional[Integer[0,65536]]",
      desc:      "The TCP/IP port used by the NAS Server to connect to the LDAP servers. The default port number for LDAP is 389 and LDAPS is 636.",
    },
    principal:          {
      type:      "Optional[String[0,1023]]",
      desc:      "Specifies the principal name for Kerberos authentication.",
    },
    profile_dn:          {
      type:      "Optional[String[0,255]]",
      desc:      "For an iPlanet LDAP server, specifies the DN of the entry with the configuration profile.",
    },
    protocol:          {
      type:      "Optional[Enum['LDAP','LDAPS']]",
      desc:      "Indicates whether the LDAP protocol uses SSL for secure network communication. SSL encrypts data over the network and provides message and server authentication.* LDAP - LDAP protocol without SSL.* LDAPS - (Default) LDAP protocol with SSL. When you enable LDAPS, make sure to specify the appropriate LDAPS port (usually port 636) and to upload an LDAPS trust certificate to the LDAP server.",
    },
    protocol_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to protocol",
    },
    realm:          {
      type:      "Optional[String[0,255]]",
      desc:      "Specifies the realm name for Kerberos authentication.",
    },
    remove_addresses:          {
      type:      "Optional[Array[String]]",
      desc:      "IP addresses to remove from the current server IP addresses list. The addresses may be IPv4 or IPv6. Error occurs if an IP address does not exist in the addresses_list. Cannot be combined with addresses.",
    },
    schema_type:          {
      type:      "Optional[Enum['RFC2307','Microsoft','Unknown']]",
      desc:      "LDAP server schema type.* RFC2307 - OpenLDAP/iPlanet schema.* Microsoft - Microsoft Identity Management for UNIX (IDMU/SFU) schema.* Unknown - Unknown protocol.",
    },
    schema_type_l10n:          {
      type:      "Optional[String]",
      desc:      "Localized message string corresponding to schema_type",
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
