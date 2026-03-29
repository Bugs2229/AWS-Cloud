############################################
# Bonus-B: Target Group + Attachment + ALB + HTTP Redirect Listener
############################################

############################################
# UPDATED Target Group Configuration
############################################
# This replaces the target group in 17-alb.tf

  #   type            = "lb_cookie"
  #   cookie_duration = 86400  # 24 hours
  #   enabled         = true
  # }


############################################
# 6) Application Load Balancer (internet-facing)
############################################

resource "aws_lb" "ultram_alb01" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.ultram_alb_sg01.id
  ]

  subnets = [
    for s in aws_subnet.public : s.id
  ]



  # Optional (enterprise touch): prevent accidental deletes
  enable_deletion_protection = false

  tags = {
    Name = var.alb_name
  }
}

############################################
# 7) HTTP Listener (80) redirects to HTTPS (443)
############################################

resource "aws_lb_listener" "ultram_http_80" {
  load_balancer_arn = aws_lb.ultram_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
