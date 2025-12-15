# S3 Gateway Endpoint (FREE)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids  # Added to route tables
  tags = {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  }
}

# ECR API Interface Endpoint (~$7/month per AZ)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpc_endpoints_security_group_id]
  private_dns_enabled = true
    tags = {
        Name = "${var.project_name}-${var.environment}-ecr-api-endpoint"
    }
}

# ECR DKR Interface Endpoint (~$7/month per AZ)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpc_endpoints_security_group_id]
  private_dns_enabled = true
  tags = {
      Name = "${var.project_name}-${var.environment}-ecr-dkr-endpoint"
  }
}

# CloudWatch Logs Interface Endpoint (~$7/month per AZ)
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.vpc_endpoints_security_group_id]
  private_dns_enabled = true
  tags = {
      Name = "${var.project_name}-${var.environment}-cloudwatch-logs-endpoint"
  }
}