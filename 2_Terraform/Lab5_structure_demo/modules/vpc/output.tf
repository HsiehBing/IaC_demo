output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

# output "public_subnet_ids" {
#   description = "List of IDs of public subnets"
#   value       = aws_subnet.public[*].id
# }

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}
output "shared_private_subnet_ids" {
  description = "List of IDs of shared private subnets"
  value = [
    for index, _ in var.availability_zones : aws_subnet.shared_private[index].id
  ]
}
output "eks_control_plane_subnet_ids" {
  description = "List of IDs of EKS control plane subnets"
  value       = aws_subnet.eks_control_plane[*].id
}

output "eks_worker_node_subnet_ids" {
  description = "List of IDs of EKS worker node subnets"
  value       = aws_subnet.eks_worker_node[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

# output "prometheus_sg_id" {
#   description = "The ID of the Prometheus security group"
#   value       = aws_security_group.sg_prometheus.id
# }

