# AWS VPC Terraform Module (Minimal)

A lightweight, foundational Terraform module for creating AWS VPC. This module creates **only the VPC resource** following your organization's modular architecture where subnets, gateways, and route tables are separate modules.

## Architecture Philosophy

This module follows a **microservice-style architecture** for infrastructure:

```
VPC Module (Foundation)
    ↓
Subnet Module (depends on VPC)
    ↓
Gateway Module (IGW, NAT, VPC Endpoints - depends on VPC & Subnets)
    ↓
Route Table Module (depends on VPC, Subnets, Gateways)
```

## Features

- ✅ **VPC with customizable CIDR block**
- ✅ **DNS hostname and DNS support configuration**
- ✅ **VPC Flow Logs (optional)**
- ✅ **Minimal and focused - only VPC resource**
- ✅ **Outputs for use in other modules**

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "git::https://github.com/your-org/vpc-module.git"

  vpc_name = "my-app-vpc"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Complete Example with Flow Logs

```hcl
module "vpc" {
  source = "git::https://github.com/your-org/vpc-module.git"

  vpc_name             = "production-vpc"
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enable VPC Flow Logs
  enable_flow_logs          = true
  flow_logs_iam_role_arn    = "arn:aws:iam::123456789012:role/vpc-flow-logs-role"
  flow_logs_destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:vpc-flow-logs"
  flow_logs_traffic_type    = "ALL"

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "Terraform"
  }
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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | n/a | yes |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `false` | no |
| flow_logs_iam_role_arn | IAM role ARN for VPC Flow Logs | `string` | `""` | no |
| flow_logs_destination_arn | Destination ARN for VPC Flow Logs | `string` | `""` | no |
| flow_logs_destination_type | Type of flow logs destination | `string` | `"cloud-watch-logs"` | no |
| flow_logs_traffic_type | Type of traffic to log | `string` | `"ALL"` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_name | The name of the VPC |
| default_security_group_id | The ID of the default security group |
| default_network_acl_id | The ID of the default network ACL |
| default_route_table_id | The ID of the default route table |
| vpc_flow_log_id | The ID of the VPC Flow Log |

## How Application Teams Use This Module

### Step 1: Create VPC (This Module)

```hcl
module "vpc" {
  source   = "git::https://github.com/your-org/vpc-module.git?ref=v1.0.0"
  vpc_name = "my-team-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  tags = {
    Team        = "my-team"
    Environment = "production"
  }
}
```

### Step 2: Create Subnets (Separate Subnet Module)

```hcl
module "subnets" {
  source = "git::https://github.com/your-org/subnet-module.git?ref=v1.0.0"
  
  vpc_id             = module.vpc.vpc_id
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  tags = {
    Team = "my-team"
  }
}
```

### Step 3: Create Gateways (Separate Gateway Module)

```hcl
module "gateways" {
  source = "git::https://github.com/your-org/gateway-module.git?ref=v1.0.0"
  
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  
  create_igw         = true
  enable_nat_gateway = true
  
  tags = {
    Team = "my-team"
  }
}
```

### Step 4: Create Route Tables (Separate Route Table Module)

```hcl
module "route_tables" {
  source = "git::https://github.com/your-org/route-table-module.git?ref=v1.0.0"
  
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  
  internet_gateway_id = module.gateways.internet_gateway_id
  nat_gateway_ids     = module.gateways.nat_gateway_ids
  
  tags = {
    Team = "my-team"
  }
}
```

## Module Structure

```
vpc/
├── main.tf           # VPC resource only
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Terraform and provider versions
├── README.md         # This file
├── .gitignore        # Git ignore file
└── examples/
    └── basic/        # Basic VPC example
```

## Related Modules

Your organization should have separate modules for:

- **Subnet Module** - Creates public, private, and database subnets
- **Gateway Module** - Creates IGW, NAT Gateway, and VPC Endpoints
- **Route Table Module** - Creates and manages route tables and routes
- **Security Group Module** - Creates and manages security groups
- **NACL Module** - Creates and manages Network ACLs

## Best Practices

1. **Use consistent CIDR planning** - Plan your CIDR blocks to avoid overlapping with other VPCs
2. **Enable DNS support** - Required for most AWS services
3. **Tag everything** - Use consistent tagging for cost tracking and resource management
4. **Enable Flow Logs for production** - Important for security and compliance
5. **Version your modules** - Use git tags (e.g., v1.0.0) when referencing modules

## VPC CIDR Planning

Recommended CIDR blocks per environment:

- **Production**: `10.0.0.0/16`
- **Staging**: `10.1.0.0/16`
- **Development**: `10.2.0.0/16`
- **Testing**: `10.3.0.0/16`

Each VPC provides 65,536 IP addresses.

## Security Considerations

- VPC Flow Logs should be enabled for production environments
- Use private subnets (from subnet module) for sensitive workloads
- Implement proper security groups (separate module)
- Use VPC endpoints (from gateway module) to reduce data transfer costs

## Support

For issues, questions, or contributions, please contact the Platform Engineering team.

## License

Internal use only - Your Organization
