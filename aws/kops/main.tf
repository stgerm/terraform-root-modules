terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name  (e.g. `kops`)"
  default     = "kops"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "domain_enabled" {
  type        = "string"
  description = "Enable DNS Zone creation for kops"
  default     = "true"
}

variable "force_destroy" {
  type        = "string"
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without errors. These objects are not recoverable."
  default     = "false"
}

variable "ssh_public_key_path" {
  type        = "string"
  description = "SSH public key path to write master public/private key pair for cluster"
  default     = "/secrets/tf/ssh"
}

variable "kops_attribute" {
  type        = "string"
  description = "Additional attribute to kops state bucket"
  default     = "state"
}

variable "complete_zone_name" {
  type        = "string"
  description = "Region or any classifier prefixed to zone name"
  default     = "$${name}.$${parent_zone_name}"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.1.5"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  attributes       = ["${var.kops_attribute}"]
  cluster_name     = "${var.region}"
  parent_zone_name = "${var.zone_name}"
  zone_name        = "${var.complete_zone_name}"
  domain_enabled   = "${var.domain_enabled}"
  force_destroy    = "${var.force_destroy}"
  region           = "${var.region}"
}

module "ssh_key_pair" {
  source              = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.2.3"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  attributes          = ["${var.region}"]
  ssh_public_key_path = "${var.ssh_public_key_path}"
  generate_ssh_key    = "true"
}
