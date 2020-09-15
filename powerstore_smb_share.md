Document: "dellemc.swagger"


Path: "/varhttps://github.com/aws/aws-sdk-go-v2/tree/master/dellemc.swagger.json")

## Smb_share



```puppet
powerstore_smb_share {
  description => "description (optional)",
  file_system_id => "file_system_id (optional)",
  is_abe_enabled => "is_ABE_enabled (optional)",
  is_branch_cache_enabled => "is_branch_cache_enabled (optional)",
  is_continuous_availability_enabled => "is_continuous_availability_enabled (optional)",
  is_encryption_enabled => "is_encryption_enabled (optional)",
  name => "name (optional)",
  offline_availability => "offline_availability (optional)",
  path => "path (optional)",
  umask => "umask (optional)",
}
```

| Name        | Type           | Required       |
| ------------- | ------------- | ------------- |
|description | String | false |
|file_system_id | String | false |
|is_abe_enabled | Boolean | false |
|is_branch_cache_enabled | Boolean | false |
|is_continuous_availability_enabled | Boolean | false |
|is_encryption_enabled | Boolean | false |
|name | String | false |
|offline_availability | String | false |
|path | String | false |
|umask | String | false |



## CRUD operations

Here is a list of endpoints that we use to create, read, update and delete the smb_share

| Operation | Path | Verb | Description | OperationID |
| ------------- | ------------- | ------------- | ------------- | ------------- |
|Create|`/smb_share`|Post|Create an SMB share.|smb_shareCreate|
|List - list all|`/smb_share`|Get|List SMB shares.|smb_shareCollectionQuery|
|List - get one|`/smb_share/%{id}`|Get|Get an SMB Share.|smb_shareInstanceQuery|
|List - get list using params|``||||
|Update|`/smb_share/%{id}`|Patch|Modify SMB share properties.|smb_shareModify|
|Delete|`/smb_share/%{id}`|Delete|Delete an SMB Share.|smb_shareDelete|