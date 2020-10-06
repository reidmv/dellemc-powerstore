Document: "swagger"


Path: "/varhttps://github.com/aws/aws-sdk-go-v2/tree/master/swagger.json")

## Storage_container



```puppet
powerstore_storage_container {
  force => "force (optional)",
  id => "id",
  name => "name",
  quota => "quota (optional)",
}
```

| Name        | Type           | Required       |
| ------------- | ------------- | ------------- |
|force | Boolean | false |
|id | String | true |
|name | String[1,64] | true |
|quota | Integer[0, 4611686018427387904] | false |



## CRUD operations

Here is a list of endpoints that we use to create, read, update and delete the storage_container

| Operation | Path | Verb | Description | OperationID |
| ------------- | ------------- | ------------- | ------------- | ------------- |
|Create|`/storage_container`|Post|Create a virtual volume (vVol) storage container.|storage_containerCreate|
|List - list all|`/storage_container`|Get|List storage containers.|storage_containerCollectionQuery|
|List - get one|`/storage_container/%{id}`|Get|Query a specific instance of storage container.|storage_containerInstanceQuery|
|List - get list using params|``||||
|Update|`/storage_container/%{id}`|Patch|Modify a storage container.|storage_containerModify|
|Delete|`/storage_container/%{id}`|Delete|Delete a storage container.|storage_containerDelete|
