/**
* ## Project: infra-content-data-admin
*
* Stores CSVs generated by Content Data.
*/

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_environment" {
  type        = "string"
  description = "AWS Environment"
}

variable "stackname" {
  type        = "string"
  description = "Stackname"
}

# Resources
# --------------------------------------------------------------
terraform {
  backend          "s3"             {}
  required_version = "= 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "1.40.0"
}

resource "aws_s3_bucket" "content_data_csvs" {
  bucket = "govuk-${var.aws_environment}-content-data-csvs"
  acl    = "public-read"

  tags {
    name            = "govuk-${var.aws_environment}-content-data-csvs"
    aws_environment = "${var.aws_environment}"
  }

  logging {
    target_bucket = "${data.terraform_remote_state.infra_monitoring.aws_logging_bucket_id}"
    target_prefix = "s3/govuk-${var.aws_environment}-content-data-csvs/"
  }

  lifecycle_rule {
    id      = "all"
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource "aws_iam_user" "content_data_admin_app" {
  name = "govuk-${var.aws_environment}-content-data-admin-app"
}

resource "aws_iam_policy" "s3_writer" {
  name        = "govuk-${var.aws_environment}-content-data-admin-app-s3-writer-policy"
  policy      = "${data.template_file.s3_writer_policy_template.rendered}"
  description = "Allows writing to the govuk-${var.aws_environment}-content-data-csvs S3 bucket"
}

resource "aws_iam_policy_attachment" "s3_writer" {
  name       = "archive-writer-policy-attachment"
  users      = ["${aws_iam_user.content_data_admin_app.name}"]
  policy_arn = "${aws_iam_policy.s3_writer.arn}"
}

data "template_file" "s3_writer_policy_template" {
  template = "${file("${path.module}/../../policies/content_data_admin_s3_writer_policy.tpl")}"

  vars {
    aws_environment = "${var.aws_environment}"
    bucket          = "${aws_s3_bucket.content_data_csvs.id}"
  }
}
