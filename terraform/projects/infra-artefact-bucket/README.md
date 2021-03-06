## Project: artefact-bucket

This creates 3 S3 buckets:

artefact: The bucket that will hold the artefacts  
artefact\_access\_logs: Bucket for logs to go to  
artefact\_replication\_destination: Bucket in another region to replicate to

It creates two IAM roles:  
artefact\_writer: used by CI to write new artefacts, and deploy instances  
to write to "deployed-to-environment" branches

artefact\_reader: used by instances to fetch artefacts

This module creates the following.
     - AWS SNS topic
     - AWS S3 Bucket event
     - AWS S3 Bucket policy.
     - AWS Lambda function.
     - AWS SNS subscription
     - AWS IAM roles and polisis for SNS and Lambda.

## Requirements

| Name | Version |
|------|---------|
| terraform | = 0.11.14 |
| aws | 2.46.0 |
| aws | 2.46.0 |
| aws | 2.46.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 2.46.0 2.46.0 2.46.0 |
| aws.secondary | 2.46.0 2.46.0 2.46.0 |
| aws.subscription | 2.46.0 2.46.0 2.46.0 |
| template | n/a |
| terraform | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/data-sources/caller_identity) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/iam_policy) |
| [aws_iam_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/iam_policy_attachment) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/iam_role) |
| [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/iam_user) |
| [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/lambda_function) |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/lambda_permission) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/s3_bucket) |
| [aws_s3_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/s3_bucket_notification) |
| [aws_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/s3_bucket_policy) |
| [aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/sns_topic) |
| [aws_sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/sns_topic_policy) |
| [aws_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/2.46.0/docs/resources/sns_topic_subscription) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |
| [terraform_remote_state](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| artefact\_source | Identifies the source artefact environment | `string` | n/a | yes |
| aws\_environment | AWS Environment | `string` | n/a | yes |
| aws\_region | AWS region | `string` | `"eu-west-1"` | no |
| aws\_s3\_access\_account | Here we define the account that will have access to the Artefact S3 bucket. | `list` | n/a | yes |
| aws\_secondary\_region | Secondary region for cross-replication | `string` | `"eu-west-2"` | no |
| aws\_subscription\_account\_id | The AWS Account ID that will appear on the subscription | `string` | n/a | yes |
| aws\_subscription\_account\_region | AWS region of the SNS topic | `string` | `"eu-west-1"` | no |
| create\_sns\_subscription | Indicates whether to create an SNS subscription | `string` | `false` | no |
| create\_sns\_topic | Indicates whether to create an SNS Topic | `string` | `false` | no |
| remote\_state\_bucket | S3 bucket we store our terraform state in | `string` | n/a | yes |
| remote\_state\_infra\_monitoring\_key\_stack | Override stackname path to infra\_monitoring remote state | `string` | `""` | no |
| replication\_setting | Whether replication is Enabled or Disabled | `string` | `"Enabled"` | no |
| stackname | Stackname | `string` | n/a | yes |
| whole\_bucket\_lifecycle\_rule\_integration\_enabled | Set to true in Integration data to only apply these rules for Integration | `string` | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| read\_artefact\_bucket\_policy\_arn | ARN of the read artefact-bucket policy |
| write\_artefact\_bucket\_policy\_arn | ARN of the write artefact-bucket policy |
