# VPC Configuration
vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"

# DNS Configuration
enable_dns_hostnames = true
enable_dns_support   = true

# Mandatory Tags
description   = "Development VPC for application testing and development workloads"
requestor     = "john.doe@example.com"
allocation_id = "APM-12345"

# Additional Tags
tags = {
  Environment = "development"
  Team        = "platform-engineering"
  ManagedBy   = "Terraform"
  Project     = "vpc-module-test"
}
