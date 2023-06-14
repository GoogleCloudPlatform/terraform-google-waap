## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Google Project ID | string | n/a | Yes |
| region | Region for cloud resources. | string | us-central1 | Yes |
| zone | Zone for managed instance groups. | string | | Yes |
| port\_name | | string | http | Yes |
| backend\_port | | number | 80 | Yes |
| service\_account | The account ID used to generate the virtual machine service account. | string | n/a | Yes |
| roles | Permissions to be added to the created service account. | list(any) | [] | Yes |
| name\_prefix | Name prefix for the instance template | string | vm-template- | Yes |
| machine\_type | Machine type to create, e.g. n1-standard-1 | string | n1-standard-1 | Yes |
| tags | Network tags, provided as a list | list(string) | [] | Yes |
| source\_image | Source disk image. If neither source\_image nor source\_image\_family is specified, defaults to the latest public Ubuntu image. | string | n/a | Yes |
| disk\_auto\_delete | Whether or not the disk should be auto-deleted. | bool | true | Yes |
| disk\_type | The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard. | string | pd-standard | Yes |
| disk\_size\_gb | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | string | 100 | Yes |
| disk\_mode | The mode in which to attach this disk, either READ\_WRITE or READ\_ONLY. | string | READ\_WRITE | Yes |
| scopes | List of scopes for the instance template service account | list(any) | [] | Yes |
| startup\_script | | string | n/a | Yes |
| network | Name of the network to deploy instances to. | string | default | Yes |
| subnetwork | The subnetwork to deploy to | string | default | Yes |
| mig\_name | Name of the managed instance group. | string | n/a | Yes |
| base\_instance\_name | The base instance name to use for instances in this group. | string | backend-vm | Yes |
| target\_size | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | number | 1 | Yes |

## Outputs

| Name | Description |
|------|-------------|
| instance\_group | Managed instance group |
