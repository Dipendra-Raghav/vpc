# VPC Configuration
vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"

# DNS Configuration
enable_dns_hostnames = true
enable_dns_support   = true

# Tags
tags = {
  Environment = "development"
  Team        = "platform-engineering"
  ManagedBy   = "Terraform"
  Project     = "vpc-module-test"
}
