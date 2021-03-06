variable "RDS_NAME" {
  type        = "string"
  default     = "rds"
  description = "RDS instance name"
}

variable "RDS_ENABLED" {
  type        = "string"
  default     = "false"
  description = "Set to true to create rds instance"
}

# Don't use `root`
# ("MasterUsername root cannot be used as it is a reserved word used by the engine")
variable "RDS_ADMIN_NAME" {
  type        = "string"
  description = "RDS DB admin user name"
}

# Must be longer than 8 chars
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "RDS_ADMIN_PASSWORD" {
  type        = "string"
  description = "RDS DB password for the admin user"
}

# Don't use `default`
# ("DatabaseName default cannot be used as it is a reserved word used by the engine")
variable "RDS_DB_NAME" {
  type        = "string"
  description = "RDS DB database name"
}

# db.t2.micro is free tier
# https://aws.amazon.com/rds/free
variable "RDS_INSTANCE_TYPE" {
  type        = "string"
  default     = "db.t2.micro"
  description = "EC2 instance type for RDS DB"
}

variable "RDS_ENGINE" {
  type        = "string"
  default     = "mysql"
  description = "RDS DB engine"
}

variable "RDS_ENGINE_VERSION" {
  type        = "string"
  default     = "5.6"
  description = "RDS DB engine version"
}

variable "RDS_PORT" {
  type        = "string"
  default     = "3306"
  description = "RDS DB port"
}

variable "RDS_DB_PARAMETER_GROUP" {
  type        = "string"
  default     = "mysql5.6"
  description = "RDS DB engine version"
}

variable "RDS_CLUSTER_ENABLED" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "RDS_SNAPSHOT" {
  type        = "string"
  default     = ""
  description = "Set to a snapshot ID to restore from snapshot"
}

variable "RDS_PARAMETER_GROUP_NAME" {
  type        = "string"
  default     = ""
  description = "Existing parameter group name to use"
}

variable "RDS_MULTI_AZ" {
  type        = "string"
  default     = "false"
  description = "Run instaces in multiple az"
}

variable "RDS_STORAGE_TYPE" {
  type        = "string"
  default     = "gp2"
  description = "Storage type"
}

variable "RDS_STORAGE_SIZE" {
  type        = "string"
  default     = "20"
  description = "Storage size"
}

variable "RDS_STORAGE_ENCRYPTED" {
  type        = "string"
  default     = "false"
  description = "Set true to encrypt storage"
}

variable "RDS_AUTO_MINOR_VERSION_UPGRADE" {
  type        = "string"
  default     = "false"
  description = "Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4)"
}

variable "RDS_ALLOW_MAJOR_VERSION_UPGRADE" {
  type        = "string"
  default     = "false"
  description = "Allow major version upgrade"
}

variable "RDS_APPLY_IMMEDIATELY" {
  type        = "string"
  default     = "true"
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
}

variable "RDS_SKIP_FINAL_SNAPSHOT" {
  type        = "string"
  default     = "false"
  description = "If true (default), no snapshot will be made before deleting DB"
}

variable "RDS_BACKUP_RETENTION_PERIOD" {
  type        = "string"
  default     = "7"
  description = "Backup retention period in days. Must be > 0 to enable backups"
}

variable "RDS_BACKUP_WINDOW" {
  type        = "string"
  default     = "22:00-03:00"
  description = "When AWS can perform DB snapshots, can't overlap with maintenance window"
}

module "rds" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-rds.git?ref=tags/0.4.1"
  enabled                     = "${var.RDS_ENABLED}"
  namespace                   = "${var.namespace}"
  stage                       = "${var.stage}"
  name                        = "${var.RDS_NAME}"
  dns_zone_id                 = "${var.zone_id}"
  host_name                   = "${var.RDS_NAME}"
  security_group_ids          = ["${module.kops_metadata.nodes_security_group_id}"]
  database_name               = "${var.RDS_DB_NAME}"
  database_user               = "${var.RDS_ADMIN_NAME}"
  database_password           = "${var.RDS_ADMIN_PASSWORD}"
  database_port               = "${var.RDS_PORT}"
  multi_az                    = "${var.RDS_MULTI_AZ}"
  storage_type                = "${var.RDS_STORAGE_TYPE}"
  allocated_storage           = "${var.RDS_STORAGE_SIZE}"
  storage_encrypted           = "${var.RDS_STORAGE_ENCRYPTED}"
  engine                      = "${var.RDS_ENGINE}"
  engine_version              = "${var.RDS_ENGINE_VERSION}"
  instance_class              = "${var.RDS_INSTANCE_TYPE}"
  db_parameter_group          = "${var.RDS_DB_PARAMETER_GROUP}"
  parameter_group_name        = "${var.RDS_PARAMETER_GROUP_NAME}"
  publicly_accessible         = "false"
  subnet_ids                  = ["${module.subnets.private_subnet_ids}"]
  vpc_id                      = "${module.vpc.vpc_id}"
  snapshot_identifier         = "${var.RDS_SNAPSHOT}"
  auto_minor_version_upgrade  = "${var.RDS_AUTO_MINOR_VERSION_UPGRADE}"
  allow_major_version_upgrade = "${var.RDS_ALLOW_MAJOR_VERSION_UPGRADE}"
  apply_immediately           = "${var.RDS_APPLY_IMMEDIATELY}"
  skip_final_snapshot         = "${var.RDS_SKIP_FINAL_SNAPSHOT}"
  copy_tags_to_snapshot       = "true"
  backup_retention_period     = "${var.RDS_BACKUP_RETENTION_PERIOD}"
  backup_window               = "${var.RDS_BACKUP_WINDOW}"
}

output "rds_instance_id" {
  value       = "${module.rds.instance_id}"
  description = "RDS ID of the instance"
}

output "rds_instance_address" {
  value       = "${module.rds.instance_address}"
  description = "RDS address of the instance"
}

output "rds_instance_endpoint" {
  value       = "${module.rds.instance_endpoint}"
  description = "RDS DNS Endpoint of the instance"
}

output "rds_port" {
  value       = "${var.RDS_PORT}"
  description = "RDS port"
}

output "rds_db_name" {
  value       = "${var.RDS_DB_NAME}"
  description = "RDS db name"
}

output "rds_root_user" {
  value       = "${var.RDS_ADMIN_NAME}"
  description = "RDS root user name"
}

output "rds_root_password" {
  value       = "${var.RDS_ADMIN_PASSWORD}"
  description = "RDS root password"
}

output "rds_hostname" {
  value       = "${module.rds.hostname}"
  description = "RDS host name of the instance"
}
