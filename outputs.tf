output "vpc_id" {
  description = "The ID of the VPC (either created or provided)"
  value       = local.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC (only if VPC was created)"
  value       = var.create_vpc ? aws_vpc.main[0].arn : null
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC (only if VPC was created)"
  value       = var.create_vpc ? aws_vpc.main[0].cidr_block : null
}

output "default_security_group_id" {
  description = "The ID of the VPC's default security group (restricted to deny all traffic)"
  value       = var.create_vpc ? aws_default_security_group.default[0].id : null
}

output "default_network_acl_id" {
  description = "The ID of the VPC's default network ACL (restricted to SSH/RDP from private networks)"
  value       = var.create_vpc ? aws_default_network_acl.default[0].id : null
}

output "default_route_table_id" {
  description = "The ID of the VPC's default route table (with TGW route if tgw_id provided)"
  value       = var.create_vpc && var.tgw_id != null ? aws_default_route_table.default[0].id : (var.create_vpc ? aws_vpc.main[0].default_route_table_id : null)
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = var.vpc_name
}

output "custom_route_table_ids" {
  description = "IDs of the custom route tables"
  value       = aws_route_table.custom[*].id
}

output "custom_route_table_arns" {
  description = "ARNs of the custom route tables"
  value       = aws_route_table.custom[*].arn
}

output "route_table_associations" {
  description = "Map of subnet IDs to route table IDs"
  value = {
    for idx, assoc in var.subnet_associations :
    assoc.subnet_id => aws_route_table.custom[assoc.route_table_index].id
  }
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.create_vpc && var.enable_flow_logs ? aws_flow_log.main[0].id : null
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC Endpoint"
  value       = var.create_vpc && var.create_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}
