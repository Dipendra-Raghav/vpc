variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
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

variable "description" {
  description = "Free-text description for governance, reporting, and cost allocation"
  type        = string
}

variable "requestor" {
  description = "Person who requested the resource for governance and visibility"
  type        = string
}

variable "allocation_id" {
  description = "Application Portfolio Manager ID for cost tracking and governance"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to add to all resources"
  type        = map(string)
  default     = {}
}
