resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # From anywhere
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # From anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    }
}

resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # ONLY from ALB!
  }
    tags = {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
    }
}

resource "aws_security_group" "vpc_endpoints" {
  name   = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # Only from within VPC (10.0.0.0/16)
  }
    tags = {
    Name = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
    }
}