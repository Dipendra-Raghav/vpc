# VPC Configuration
create_vpc           = true
vpc_name             = "dev-vpc"
vpc_cidr             = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support   = true

# VPC Mandatory Tags
vpc_is_description   = "Development VPC for application testing and development workloads"
vpc_is_requestor     = "john.doe@example.com"
vpc_is_allocation_id = "APM-12345"
vpc_is_iac_repo      = "vpc"
vpc_is_iac           = "terraform"
vpc_is_iac_version   = "1.0.0"

# VPC Additional Tags
vpc_tags = {
  Environment = "development"
  Team        = "platform-engineering"
  ManagedBy   = "Terraform"
  Project     = "vpc-module-test"
}

# Custom Route Tables
create_custom_route_tables = false
# custom_route_table_names   = ["app-route-table", "db-route-table"]

# Route Table Mandatory Tags
# route_table_is_description   = "Custom route tables for application and database tiers"
# route_table_is_requestor     = "jane.smith@example.com"
# route_table_is_allocation_id = "APM-12345"
# route_table_is_iac_repo      = "vpc"
# route_table_is_iac           = "terraform"
# route_table_is_iac_version   = "1.0.0"

# Route Table Additional Tags
# route_table_tags = {
#   Environment = "development"
#   Team        = "networking"
# }

# Subnet Associations (Update with your actual subnet IDs after creating subnets)
# subnet_associations = [
#   {
#     subnet_id         = "subnet-12345678"
#     route_table_index = 0
#   },
#   {
#     subnet_id         = "subnet-87654321"
#     route_table_index = 1
#   }
# ]

# VPC Flow Logs Configuration
enable_flow_logs          = false  # Set to true to enable
flow_logs_iam_role_arn    = null   # Provide IAM role ARN when enabling
flow_logs_s3_bucket_arn   = "arn:aws:s3:::sh-consolidated-vpcflowlogs/flow-logs/"

# S3 Gateway Endpoint
create_s3_endpoint = false  # Set to true to enable
aws_region         = "us-east-1"

# Default Security Group Restriction
restrict_default_sg = false  # Set to true to deny all traffic in default SG

# Default Network ACL Restriction
restrict_default_nacl = false  # Set to true to allow only SSH/RDP from private networks

# Transit Gateway Configuration
tgw_id = null  # Provide TGW ID to route 0.0.0.0/0 -> TGW in default route table
# Example: tgw_id = "tgw-0123456789abcdef0"
