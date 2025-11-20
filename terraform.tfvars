# VPC Configuration
create_vpc           = true
account_name         = "infra-core-nonprod"
vpc_name             = "vpc-test"
vpc_cidr             = "10.182.250.0/24"
enable_dns_hostnames = true
enable_dns_support   = true

# VPC Mandatory Tags
vpc_is_description   = "Test VPC with all features enabled for module validation"
vpc_is_requestor     = "platform-team@example.com"
vpc_is_allocation_id = "APM-TEST-001"
vpc_is_iac_repo      = "https://github.com/company/vpc-module"
vpc_is_iac           = "terraform"
vpc_is_iac_version   = "1.0.0"

# VPC Additional Tags
vpc_tags = {
  Environment = "sandbox"
  Team        = "platform-engineering"
  ManagedBy   = "Terraform"
  Project     = "vpc-module-comprehensive-test"
  CostCenter  = "Engineering"
}

# Custom Route Tables - ENABLED
create_custom_route_tables = true
custom_route_table_names   = ["app-route-table"]

# Route Table Mandatory Tags
route_table_is_description   = "Custom route tables for multi-tier architecture testing"
route_table_is_requestor     = "network-team@example.com"
route_table_is_allocation_id = "APM-TEST-001"
route_table_is_iac_repo      = "https://github.com/company/vpc-module"
route_table_is_iac           = "terraform"
route_table_is_iac_version   = "1.0.0"

# Route Table Additional Tags
route_table_tags = {
  Environment = "sandbox"
  Team        = "networking"
  Purpose     = "custom-routing"
}

# Subnet Associations - SKIP (no subnets created yet)
subnet_associations = []

# VPC Flow Logs Configuration - ENABLED
enable_flow_logs        = true
flow_logs_iam_role_arn  = null  # AWS will auto-create permissions for S3
flow_logs_s3_bucket_arn = "arn:aws:s3:::sh-consolidated-vpcflowlogs"

# S3 Gateway Endpoint - ENABLED
create_s3_endpoint = true
aws_region         = "us-east-1"

# Transit Gateway Configuration - DISABLED (enable after TGW attachment exists)
tgw_id = null  # Set to "tgw-0f6bb6c26c80995cf" after TGW attachment is created
