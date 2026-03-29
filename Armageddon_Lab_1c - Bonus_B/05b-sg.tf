resource "aws_security_group" "ec2" {
  name        = "ec2-sg"
  description = "Security group for EC2 web application instance"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  tags = {
    Name = "ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Inbound: HTTP from allowed CIDRs
resource "aws_vpc_security_group_ingress_rule" "ec2_http" {

  # 'toset' converts and packages your list variable into a format that 'for_each' can accept.
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.ec2.id
  description       = "HTTP from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value

  tags = {
    Name = "ec2-http-${replace(each.value, "/", "-")}"
  }
}

# # EC2 Outbound: All traffic (required for package installation and AWS API calls)
resource "aws_vpc_security_group_egress_rule" "ec2_all_outbound" {
  security_group_id = aws_security_group.ec2.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "ec2-outbound"
  }
}

# ================================================================ #

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS MySQL - allows access only from EC2 SG"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  tags = {
    Name = "rds-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Inbound: MySQL from EC2 security group only (SG-to-SG reference)
resource "aws_vpc_security_group_ingress_rule" "rds_mysql_from_ec2" {
  security_group_id = aws_security_group.rds.id
  description       = "MySQL from EC2 security group"
  ip_protocol       = "tcp"
  from_port         = var.db_port
  to_port           = var.db_port

  # SG-to-SG reference - this is the critical security pattern
  referenced_security_group_id = aws_security_group.ec2.id

  tags = {
    Name = "rds-mysql-from-ec2"
  }
}

resource "aws_security_group" "vpce" {
  name        = "lab-vpce-sg"
  description = "Allow HTTPS from EC2 to VPC interface endpoints"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  ingress {
    description     = "HTTPS from EC2 SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ultram_alb_sg01" {
  name        = "ultram-alb-sg"
  description = "Security group for Ultram ALB"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






