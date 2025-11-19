# VPC Configuration
variable "create_vpc" {
  description = "Whether to create a new VPC or use an existing one"
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "ID of existing VPC (required if create_vpc = false)"
  type        = string
  default     = null

  validation {
    condition     = var.create_vpc || var.existing_vpc_id != null
    error_message = "existing_vpc_id must be provided when create_vpc is false."
  }
}

variable "vpc_name" {
  description = "Name of the VPC (will be prefixed with account_name)"
  type        = string
}

variable "account_name" {
  description = "Account name for resource naming standard (e.g., 'prod', 'dev', 'staging')"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (required only if create_vpc = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_vpc ? var.vpc_cidr != "" : true
    error_message = "vpc_cidr is required when create_vpc is true."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# VPC Mandatory Tags
variable "vpc_is_description" {
  description = "Free-text description for VPC governance, reporting, and cost allocation"
  type        = string
}

variable "vpc_is_requestor" {
  description = "Person who requested the VPC for governance and visibility"
  type        = string
}

variable "vpc_is_allocation_id" {
  description = "Application Portfolio Manager ID for VPC cost tracking and governance"
  type        = string
}

variable "vpc_is_iac_repo" {
  description = "IAC repository name for VPC"
  type        = string
}

variable "vpc_is_iac" {
  description = "IAC tool used (e.g., terraform, cloudformation)"
  type        = string
}

variable "vpc_is_iac_version" {
  description = "IAC version for VPC"
  type        = string
}

variable "vpc_tags" {
  description = "Additional tags for VPC"
  type        = map(string)
  default     = {}
}

# Route Table Configuration
variable "create_custom_route_tables" {
  description = "Whether to create custom route tables"
  type        = bool
  default     = false
}

variable "custom_route_table_names" {
  description = "List of names for custom route tables to create"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_custom_route_tables ? length(var.custom_route_table_names) > 0 : true
    error_message = "custom_route_table_names cannot be empty when create_custom_route_tables is true."
  }
}

variable "subnet_associations" {
  description = "List of subnet associations. Each item should have subnet_id and route_table_index"
  type = list(object({
    subnet_id          = string
    route_table_index  = number
  }))
  default = []

  validation {
    condition = alltrue([
      for assoc in var.subnet_associations :
      assoc.route_table_index >= 0 && assoc.route_table_index < length(var.custom_route_table_names)
    ])
    error_message = "route_table_index must be a valid index within the custom_route_table_names list."
  }
}

# Route Table Mandatory Tags
variable "route_table_is_description" {
  description = "Free-text description for Route Table governance, reporting, and cost allocation (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_description != "" : true
    error_message = "route_table_is_description is required when create_custom_route_tables is true."
  }
}

variable "route_table_is_requestor" {
  description = "Person who requested the Route Table for governance and visibility (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_requestor != "" : true
    error_message = "route_table_is_requestor is required when create_custom_route_tables is true."
  }
}

variable "route_table_is_allocation_id" {
  description = "Application Portfolio Manager ID for Route Table cost tracking and governance (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_allocation_id != "" : true
    error_message = "route_table_is_allocation_id is required when create_custom_route_tables is true."
  }
}

variable "route_table_is_iac_repo" {
  description = "IAC repository name for Route Table (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_iac_repo != "" : true
    error_message = "route_table_is_iac_repo is required when create_custom_route_tables is true."
  }
}

variable "route_table_is_iac" {
  description = "IAC tool used for Route Table (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_iac != "" : true
    error_message = "route_table_is_iac is required when create_custom_route_tables is true."
  }
}

variable "route_table_is_iac_version" {
  description = "IAC version for Route Table (required if create_custom_route_tables = true)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_custom_route_tables ? var.route_table_is_iac_version != "" : true
    error_message = "route_table_is_iac_version is required when create_custom_route_tables is true."
  }
}

variable "route_table_tags" {
  description = "Additional tags for Route Tables"
  type        = map(string)
  default     = {}
}

# VPC Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_iam_role_arn" {
  description = "IAM role ARN for VPC Flow Logs (required if enable_flow_logs = true)"
  type        = string
  default     = null
}

variable "flow_logs_s3_bucket_arn" {
  description = "S3 bucket ARN for VPC Flow Logs destination"
  type        = string
  default     = "arn:aws:s3:::sh-consolidated-vpcflowlogs/flow-logs/"
}

variable "flow_logs_custom_format" {
  description = "Custom log format for VPC Flow Logs"
  type        = string
  default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr}"
}

# S3 Endpoint Configuration
variable "create_s3_endpoint" {
  description = "Create S3 VPC Gateway Endpoint"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS Region for VPC Endpoint service names"
  type        = string
  default     = "us-east-1"
}

# Transit Gateway Configuration
variable "tgw_id" {
  description = "Transit Gateway ID for default route table (0.0.0.0/0 -> TGW)"
  type        = string
  default     = null
}
