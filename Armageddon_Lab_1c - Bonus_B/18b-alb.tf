############################################
# ALB Security Group (Replaces incomplete section in 05-sg.tf)
############################################
# WHY: The ALB needs its own security group to control what traffic
# can reach it (inbound) and what it can send to targets (outbound)

resource "aws_security_group" "ultram_alb_sg02" {
  name        = "ultram-alb-sg"
  description = "Security group for public ALB - allows HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  tags = {
    Name = "ultram-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# ALB Inbound: HTTP (80) from Internet
############################################
# WHY: Allow public HTTP traffic so the redirect to HTTPS works
resource "aws_vpc_security_group_ingress_rule" "alb_http_80" {
  security_group_id = aws_security_group.ultram_alb_sg02.id
  description       = "HTTP from Internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "alb-http-80"
  }
}

############################################
# ALB Inbound: HTTPS (443) from Internet
############################################
# WHY: Allow public HTTPS traffic - this is how users access your app
resource "aws_vpc_security_group_ingress_rule" "alb_https_443" {
  security_group_id = aws_security_group.ultram_alb_sg02.id
  description       = "HTTPS from Internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "alb-https-443"
  }
}

############################################
# ALB Outbound: To EC2 Targets on App Port
############################################
# WHY: ALB needs to forward traffic to your EC2 instances on port 80
# This is security group to security group communication
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2_targets" {
  security_group_id = aws_security_group.ultram_alb_sg02.id
  description       = "Forward to EC2 targets on app port"
  ip_protocol       = "tcp"
  from_port         = var.app_port
  to_port           = var.app_port
  
  # Security group to security group reference
  referenced_security_group_id = aws_security_group.ec2.id

  tags = {
    Name = "alb-to-ec2-${var.app_port}"
  }
}

############################################
# EC2 Inbound: HTTP from ALB Security Group
############################################
# WHY: Your EC2 instances need to accept traffic from the ALB
# This REPLACES or AUGMENTS the existing ec2_http rule in 05-sg.tf
# Using SG-to-SG reference is more secure than CIDR ranges

resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTP from ALB"
  ip_protocol       = "tcp"
  from_port         = var.app_port
  to_port           = var.app_port
  
  # Allow traffic FROM the ALB security group
  referenced_security_group_id = aws_security_group.ultram_alb_sg02.id

  tags = {
    Name = "ec2-from-alb-${var.app_port}"
  }
}
