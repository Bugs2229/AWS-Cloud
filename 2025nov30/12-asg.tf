resource "aws_autoscaling_group" "man-up-asg" {
  vpc_zone_identifier  = [aws_subnet.private-us-east-1a.id, 
                           aws_subnet.private-us-east-1b.id, 
                           aws_subnet.private-us-east-1c.id]
  #desired_capacity     = 2
  max_size             = 6
  min_size             = 3
  default_cooldown = 60
  default_instance_warmup = 60
  health_check_grace_period = 120
  health_check_type       = "ELB"

  force_delete = true

  target_group_arns = [aws_lb_target_group.alb.arn]

    launch_template {
        id      = aws_launch_template.man-up-lt.id
        version = "$Latest"
    }

    tag {
      key = "Name"
      value = "web-app"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "web_cpu" {
name = "web-cpu-policy"
autoscaling_group_name = aws_autoscaling_group.man-up-asg.name
policy_type = "TargetTrackingScaling"

target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }
  target_value = 50.0
 }
}