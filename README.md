# AWS VPC Terraform Module

A comprehensive Terraform module for creating and managing AWS VPCs with enterprise-grade security, monitoring, and networking features. This module includes VPC creation, custom route tables, flow logs, S3 endpoints, and mandatory security controls.

## Features

### Core Components
- ✅ **VPC Creation** - Customizable CIDR with DNS support (optional)
- ✅ **Flexible VPC Mode** - Create new VPC or use existing VPC ID
- ✅ **Custom Route Tables** - Multiple route tables with subnet associations
- ✅ **Resource Naming** - Follows `<account_name>-<vpc_name>-<resource_type>` standard

### Security & Compliance
- ✅ **Default Security Group** - Automatically denies all inbound/outbound traffic
- ✅ **Default Network ACL** - SSH/RDP restricted to private networks (10.0.0.0/8, 172.16.0.0/12, 162.82.0.0/16)
- ✅ **Mandatory Tagging** - 6 required "Is:*" tags for governance
- ✅ **Tag Lifecycle Management** - `ignore_changes` prevents tag drift

### Networking & Monitoring
- ✅ **VPC Flow Logs** - S3 destination with custom 20+ field format
- ✅ **S3 Gateway Endpoint** - Private S3 access without NAT/IGW costs
- ✅ **Transit Gateway Integration** - Optional default route (0.0.0.0/0 → TGW)

## Usage

### Minimal VPC Creation

```hcl
module "vpc" {
  source = "./vpc"

  # VPC Configuration
  create_vpc           = true
  account_name         = "prod"
  vpc_name             = "app-vpc"
  vpc_cidr             = "10.182.250.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Mandatory Tags
  vpc_is_description   = "Production application VPC"
  vpc_is_requestor     = "platform-team@example.com"
  vpc_is_allocation_id = "APM-12345"
  vpc_is_iac_repo      = "https://github.com/company/vpc-module"
  vpc_is_iac           = "terraform"
  vpc_is_iac_version   = "1.0.0"
}
```

### VPC with Flow Logs and S3 Endpoint

```hcl
module "vpc" {
  source = "./vpc"

  # VPC Configuration
  create_vpc   = true
  account_name = "prod"
  vpc_name     = "app-vpc"
  vpc_cidr     = "10.182.250.0/24"

  # Mandatory Tags
  vpc_is_description   = "Production VPC with monitoring"
  vpc_is_requestor     = "platform-team@example.com"
  vpc_is_allocation_id = "APM-12345"
  vpc_is_iac_repo      = "https://github.com/company/vpc-module"
  vpc_is_iac           = "terraform"
  vpc_is_iac_version   = "1.0.0"

  # VPC Flow Logs
  enable_flow_logs        = true
  flow_logs_s3_bucket_arn = "arn:aws:s3:::company-vpcflowlogs"

  # S3 Gateway Endpoint
  create_s3_endpoint = true
  aws_region         = "us-east-1"
}
```

### VPC with Custom Route Tables

```hcl
module "vpc" {
  source = "./vpc"

  # VPC Configuration
  create_vpc   = true
  account_name = "prod"
  vpc_name     = "app-vpc"
  vpc_cidr     = "10.182.250.0/24"

  # VPC Mandatory Tags
  vpc_is_description   = "Production VPC"
  vpc_is_requestor     = "platform-team@example.com"
  vpc_is_allocation_id = "APM-12345"
  vpc_is_iac_repo      = "https://github.com/company/vpc-module"
  vpc_is_iac           = "terraform"
  vpc_is_iac_version   = "1.0.0"

  # Custom Route Tables
  create_custom_route_tables = true
  custom_route_table_names   = ["public-rt", "private-rt"]

  # Route Table Mandatory Tags
  route_table_is_description   = "Custom route tables"
  route_table_is_requestor     = "network-team@example.com"
  route_table_is_allocation_id = "APM-12345"
  route_table_is_iac_repo      = "https://github.com/company/vpc-module"
  route_table_is_iac           = "terraform"
  route_table_is_iac_version   = "1.0.0"
}
```

### Using Existing VPC

```hcl
module "route_tables" {
  source = "./vpc"

  # Use Existing VPC
  create_vpc      = false
  existing_vpc_id = "vpc-xxxxx"
  account_name    = "prod"
  vpc_name        = "existing-vpc"

  # Custom Route Tables
  create_custom_route_tables = true
  custom_route_table_names   = ["app-rt", "db-rt"]

  # Route Table Mandatory Tags
  route_table_is_description   = "Application route tables"
  route_table_is_requestor     = "app-team@example.com"
  route_table_is_allocation_id = "APM-67890"
  route_table_is_iac_repo      = "https://github.com/company/vpc-module"
  route_table_is_iac           = "terraform"
  route_table_is_iac_version   = "1.0.0"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

### VPC Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vpc | Whether to create a new VPC | `bool` | `true` | no |
| existing_vpc_id | ID of existing VPC (required if create_vpc = false) | `string` | `null` | conditional |
| account_name | Account name for resource naming | `string` | n/a | yes |
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block (required if create_vpc = true) | `string` | `""` | conditional |
| enable_dns_hostnames | Enable DNS hostnames | `bool` | `true` | no |
| enable_dns_support | Enable DNS support | `bool` | `true` | no |

### VPC Mandatory Tags

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| vpc_is_description | Free-text description | `string` | yes |
| vpc_is_requestor | Person/team who requested the VPC | `string` | yes |
| vpc_is_allocation_id | APM ID for cost tracking | `string` | yes |
| vpc_is_iac_repo | IAC repository URL | `string` | yes |
| vpc_is_iac | IAC tool (e.g., 'terraform') | `string` | yes |
| vpc_is_iac_version | IAC version | `string` | yes |
| vpc_tags | Additional optional tags | `map(string)` | no |

### Route Table Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_custom_route_tables | Create custom route tables | `bool` | `false` | no |
| custom_route_table_names | List of route table names | `list(string)` | `[]` | conditional |
| route_table_is_description | Route table description | `string` | `""` | conditional* |
| route_table_is_requestor | Requestor email/name | `string` | `""` | conditional* |
| route_table_is_allocation_id | APM allocation ID | `string` | `""` | conditional* |
| route_table_is_iac_repo | IAC repository | `string` | `""` | conditional* |
| route_table_is_iac | IAC tool | `string` | `""` | conditional* |
| route_table_is_iac_version | IAC version | `string` | `""` | conditional* |

*Required when `create_custom_route_tables = true`

### Flow Logs & Endpoints

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `false` | no |
| flow_logs_s3_bucket_arn | S3 bucket ARN for flow logs | `string` | `""` | conditional |
| create_s3_endpoint | Create S3 Gateway Endpoint | `bool` | `false` | no |
| aws_region | AWS region | `string` | `"us-east-1"` | no |

### Transit Gateway

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tgw_id | Transit Gateway ID for default route | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC (created or existing) |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_name | The name of the VPC |
| default_security_group_id | ID of restricted default security group |
| default_network_acl_id | ID of restricted default network ACL |
| default_route_table_id | ID of default route table (with TGW route if configured) |
| custom_route_table_ids | List of custom route table IDs |
| custom_route_table_arns | List of custom route table ARNs |
| route_table_associations | Map of subnet IDs to route table IDs |
| vpc_flow_log_id | ID of VPC Flow Log (if enabled) |
| s3_vpc_endpoint_id | ID of S3 VPC Endpoint (if created) |

## Default Resource Behavior

When `create_vpc = true`, the module automatically configures default resources:

### Default Security Group
- **Behavior**: Denies all inbound and outbound traffic
- **Purpose**: Forces explicit security group creation
- **Lifecycle**: Tags are ignored to prevent drift

### Default Network ACL
- **Inbound Rules**:
  - SSH (22) from 10.0.0.0/8, 172.16.0.0/12, 162.82.0.0/16
  - RDP (3389) from 10.0.0.0/8, 172.16.0.0/12, 162.82.0.0/16
- **Outbound Rules**: Allow all
- **Purpose**: Restricts remote access to private networks only

### Default Route Table
- **Routes**: Local route + optional TGW route (0.0.0.0/0 → TGW)
- **Purpose**: Central routing for subnets not explicitly associated

## VPC Flow Logs Format

When enabled, flow logs use a custom 20+ field format:
```
${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status} ${vpc-id} ${subnet-id} ${instance-id} ${tcp-flags} ${type} ${pkt-srcaddr} ${pkt-dstaddr}
```

## Resource Naming Convention

All resources follow: `<account_name>-<vpc_name>-<resource_type>`

Examples:
- VPC: `prod-app-vpc`
- Default SG: `prod-app-vpc-default-sg`
- Flow Logs: `prod-app-vpc-flow-logs`
- S3 Endpoint: `prod-app-vpc-s3-endpoint`

## Validation Rules

The module includes comprehensive validation:
- VPC CIDR required when `create_vpc = true`
- Existing VPC ID required when `create_vpc = false`
- Custom route table names cannot be empty when creating route tables
- Route table mandatory tags required when creating custom route tables
- Subnet association indexes must be within route table count bounds

## Testing

Recommended testing CIDRs:
- Internal: `10.182.250.0/24`, `10.182.251.0/24`, `10.182.252.0/24`, `10.182.253.0/24`
- DMZ: `172.19.250.0/24`, `172.19.251.0/24`, `172.19.252.0/24`, `172.19.253.0/24`

## Notes

- **TGW Attachment**: This module does NOT create TGW attachments. Use a separate TGW module.
- **Subnets**: Create subnets using a separate subnet module.
- **Route53**: DNS management should use a dedicated Route53 module.
- **Tag Lifecycle**: All resources use `ignore_changes = [tags]` to prevent external tag modifications from causing drift.

## License

MIT
