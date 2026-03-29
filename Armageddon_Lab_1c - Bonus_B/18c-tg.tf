############################################
# UPDATED Target Group Configuration
############################################
# This replaces the target group in 17-alb.tf
# WHY: The health check needs to point to "/" instead of "/health"
# because your Flask app responds to the root path

resource "aws_lb_target_group" "ultram_tg01" {
  name        = var.alb_target_group_name
  target_type = "instance"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ultram_vpc_01.id

  # Health check configuration
  # WHY: ALB uses health checks to determine if targets are ready to receive traffic
  # Your Flask app responds at "/" so we check that instead of "/health"
  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"  # CHANGED FROM "/health" - your app responds here
    matcher             = "200-399"  # Any 2xx or 3xx response is healthy
    interval            = 30         # Check every 30 seconds
    timeout             = 5          # Wait 5 seconds for response
    healthy_threshold   = 2          # 2 consecutive successes = healthy
    unhealthy_threshold = 2          # 2 consecutive failures = unhealthy
  }

  # Connection draining settings
  # WHY: When an instance is deregistering, give in-flight requests time to complete
  deregistration_delay = 30

  # Stickiness (optional)
  # WHY: For session-based apps, you might want requests from the same client
  # to go to the same target. Not needed for your stateless app, but good to know.
  # Uncomment if needed:
  # stickiness {
  #   type            = "lb_cookie"
  #   cookie_duration = 86400  # 24 hours
  #   enabled         = true
  # }

  tags = {
    Name = var.alb_target_group_name
  }
}

############################################
# Register EC2 Instance to Target Group
############################################
# WHY: This actually adds your EC2 instance as a target
# The ALB will route traffic to this instance on port 80
resource "aws_lb_target_group_attachment" "ultram_ec2_attach" {
  target_group_arn = aws_lb_target_group.ultram_tg01.arn
  target_id        = aws_instance.ec2-lab-app.id
  port             = var.app_port
}

