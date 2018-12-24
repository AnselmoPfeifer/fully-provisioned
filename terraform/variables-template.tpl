provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}

terraform {
  backend "s3" {
    bucket = "<AWS_S3_BUCKET>"
    key    = "terraform/backend/terraform.tfstate"
    region = "<AWS_DEFAULT_REGION>"
  }
}

variable "aws_region" {
  default = "<AWS_DEFAULT_REGION>"
}

variable "aws_ami" {
  default = "<AWS_AMI_ID>"
}

variable "label" {
  default = "<AWS_LABEL>"
}