# Terragrunt Infrastructure repository
  

## Repository structure
Following is repository structure which introduces multi-layer layout to support:
- cloud layer to support multi-cloud deployment
- account layer to support multi-account deployment within same cloud provider
- region layer to support multi-region deployment within same account
- env layer to support multi-environment deployment withint same region
- service layer to define KL Data team services to be deployed
  These layers can be changed/removed after discussion...

Example layout structure:
```
.
+-- terragrunt.hcl - root hcl file
+-- cloud-provider(aws/gcp/azure) - cloud layer
|   +-- terragrunt.hcl - cloud shared variables/terraform blocks
|   +-- account(account1, account2, etc) - account layer
|       +-- account.hcl - account shared variables/terraform blocks
|       +-- region(eu-west-2) - region layer
| 		    +-- region.hcl - region shared variables/terraform blocks
|           +-- env(dev/qa/prod) - environment layer
|               +-- env.hcl - environment shared variables/terraform blocks
|         		+-- service(s3 buckets, vpc, etc) - service layer
|          		    +-- terragrunt.hcl - service hcl file
```

Artifact and Layer descriptions
### root hcl file

This is root configuration file used to aggregate variables from underlying layers(directories):
- stages: non-prod & prod
- region/location
- environment: dev/qa/prod

### cloud layer
Used to define multi-cloud deployment.
This layer defines cloud specific shared variables to be reused by any underlying service.
It also generates dynamically 2 terraform required artifacts:
- backend.tf - remote state config
- provider.tf - cloud provider config


### account layer
This layer defines account specific shared variables to be reused by any underlying service.

### region layer
This layer defines region specific shared variables to be reused by any underlying service.

### envionrment layer
This layer defines environment specific shared variables to be reused by any underlaying service.

### service layer
This is place of service definition.


### _envcommon
This layer is to define environment common variables/behaviors to be shared by single or multiple services and it's 
more a placeholder when any kind of upper shared layers doesn't feel like the right place to be used for specific 
variables.


### Running Terragrunt

- ensure you have terragrunt installed: [Terragrunt-getting-started](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- cd into the layer/project you want to run (it must have a terragrunt.hcl)
  - e.g cd aws/account1/eu-west-2/dev/my-s3-bucket/
- run:

```buildoutcfg
# terragrunt [init, plan, apply]
```

