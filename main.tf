# VPC Resource (only if creating new VPC)
resource "aws_vpc" "main" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name = "${var.account_name}-${var.vpc_name}"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# Local variables
locals {
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : var.existing_vpc_id
  
  # VPC common tags
  vpc_common_tags = {
    "Is:description"    = var.vpc_is_description
    "Is:requestor"      = var.vpc_is_requestor
    "Is:allocation-id"  = var.vpc_is_allocation_id
    "Is:iac-repo"       = var.vpc_is_iac_repo
    "Is:iac"            = var.vpc_is_iac
    "Is:iac-version"    = var.vpc_is_iac_version
  }
  
  # Route Table common tags
  route_table_common_tags = {
    "Is:description"    = var.route_table_is_description
    "Is:requestor"      = var.route_table_is_requestor
    "Is:allocation-id"  = var.route_table_is_allocation_id
    "Is:iac-repo"       = var.route_table_is_iac_repo
    "Is:iac"            = var.route_table_is_iac
    "Is:iac-version"    = var.route_table_is_iac_version
  }
}

# Custom Route Tables
resource "aws_route_table" "custom" {
  count  = var.create_custom_route_tables ? length(var.custom_route_table_names) : 0
  vpc_id = local.vpc_id

  tags = merge(
    var.route_table_tags,
    local.route_table_common_tags,
    {
      Name = var.custom_route_table_names[count.index]
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# Route Table Association to Subnets (Optional)
resource "aws_route_table_association" "custom" {
  count          = var.create_custom_route_tables && length(var.subnet_associations) > 0 ? length(var.subnet_associations) : 0
  subnet_id      = var.subnet_associations[count.index].subnet_id
  route_table_id = aws_route_table.custom[var.subnet_associations[count.index].route_table_index].id
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  count                = var.create_vpc && var.enable_flow_logs ? 1 : 0
  iam_role_arn         = var.flow_logs_iam_role_arn
  log_destination      = var.flow_logs_s3_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main[0].id
  log_format           = var.flow_logs_custom_format

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name = "${var.account_name}-${var.vpc_name}-flow-logs"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  count        = var.create_vpc && var.create_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.main[0].id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name = "${var.account_name}-${var.vpc_name}-s3-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# S3 Endpoint Route Table Association
resource "aws_vpc_endpoint_route_table_association" "s3_custom" {
  count           = var.create_vpc && var.create_s3_endpoint && var.create_custom_route_tables ? length(aws_route_table.custom) : 0
  route_table_id  = aws_route_table.custom[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}

# Default Security Group - Block All Traffic
resource "aws_default_security_group" "default" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name            = "${var.account_name}-${var.vpc_name}-default-sg"
      "Is:description" = "Restricted default security group - deny all traffic"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# Default Network ACL
resource "aws_default_network_acl" "default" {
  count                  = var.create_vpc ? 1 : 0
  default_network_acl_id = aws_vpc.main[0].default_network_acl_id

  # SSH from private networks
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "172.16.0.0/12"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "162.82.0.0/16"
    from_port  = 22
    to_port    = 22
  }

  # RDP from private networks
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 210
    action     = "allow"
    cidr_block = "172.16.0.0/12"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 220
    action     = "allow"
    cidr_block = "162.82.0.0/16"
    from_port  = 3389
    to_port    = 3389
  }

  # Allow all outbound
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name = "${var.account_name}-${var.vpc_name}-default-nacl"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# Default Route Table - Route to TGW
resource "aws_default_route_table" "default" {
  count                  = var.create_vpc && var.tgw_id != null ? 1 : 0
  default_route_table_id = aws_vpc.main[0].default_route_table_id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }

  tags = merge(
    var.vpc_tags,
    local.vpc_common_tags,
    {
      Name            = "${var.account_name}-${var.vpc_name}-default-rt"
      "Is:description" = "Default route table with TGW route"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
} 
