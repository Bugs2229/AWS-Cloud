############################################
# Lab 1C Bonus-B: Enterprise-Grade ALB Stack
# - Route53 DNS Management
# - ACM TLS Certificate with DNS Validation
# - HTTPS Listener on ALB
# - WAF Protection
# - CloudWatch Dashboard & Alarms
############################################

############################################
# 1) Route53 Hosted Zone
############################################
# WHY: We need a hosted zone to manage DNS records for ultram.com
# This allows us to create DNS validation records for ACM and point
# the app subdomain to our ALB
resource "aws_route53_zone" "ultram_zone" {
  name = var.domain_name

  tags = {
    Name = "${var.domain_name}-zone"
  }
}

############################################
# 2) ACM Certificate for app.ultram.com
############################################
# WHY: We need a valid TLS certificate to enable HTTPS on our ALB
# ACM provides free certificates that auto-renew, but require validation
# to prove we own the domain
resource "aws_acm_certificate" "ultram_cert" {
  domain_name       = var.tls_domain_name  # app.ultram.com
  validation_method = "DNS"

  # IMPORTANT: This ensures Terraform creates a new cert before destroying
  # the old one during updates, preventing downtime
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.tls_domain_name}-cert"
  }
}

############################################
# 3) Route53 Validation Records for ACM
############################################
# WHY: ACM requires us to prove domain ownership by creating specific
# DNS records. This creates those records automatically.
resource "aws_route53_record" "ultram_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ultram_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.ultram_zone.zone_id
}

############################################
# 4) ACM Certificate Validation Waiter
############################################
# WHY: This tells Terraform to wait until ACM confirms the certificate
# is validated before proceeding. Without this, the HTTPS listener
# would fail because the cert isn't ready yet.
resource "aws_acm_certificate_validation" "ultram_cert_wait" {
  certificate_arn         = aws_acm_certificate.ultram_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ultram_cert_validation : record.fqdn]
}

############################################
# 5) HTTPS Listener (443) on ALB
############################################
# WHY: This is the actual listener that handles HTTPS traffic on port 443
# It uses the validated certificate and forwards traffic to our target group
resource "aws_lb_listener" "ultram_https_443" {
  load_balancer_arn = aws_lb.ultram_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # Modern TLS policy
  certificate_arn   = aws_acm_certificate_validation.ultram_cert_wait.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ultram_tg01.arn
  }

  # Ensure certificate is validated before creating listener
  depends_on = [aws_acm_certificate_validation.ultram_cert_wait]
}

############################################
# 6) Route53 A Record (app.ultram.com -> ALB)
############################################
# WHY: This creates the DNS record that points app.ultram.com to your ALB
# Users will access your app via https://app.ultram.com
resource "aws_route53_record" "ultram_app_alias" {
  zone_id = aws_route53_zone.ultram_zone.zone_id
  name    = var.tls_domain_name  # app.ultram.com
  type    = "A"

  alias {
    name                   = aws_lb.ultram_alb01.dns_name
    zone_id                = aws_lb.ultram_alb01.zone_id
    evaluate_target_health = true
  }
}

############################################
# 7) WAF Web ACL (Regional for ALB)
############################################
# WHY: WAF provides protection against common web exploits and attacks
# This creates a Web ACL with AWS Managed Rules for baseline protection
resource "aws_wafv2_web_acl" "ultram_waf" {
  name  = var.waf_name
  scope = "REGIONAL"  # Must be REGIONAL for ALB (CLOUDFRONT for CloudFront)

  default_action {
    allow {}  # Allow traffic by default unless a rule blocks it
  }

  # Rule 1: AWS Managed Common Rule Set
  # Protects against common threats like SQLi, XSS
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}  # Don't override; use rule group's actions
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: Known Bad Inputs Rule Set
  # Blocks requests with patterns known to be malicious
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_name}-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = var.waf_name
  }
}

############################################
# 8) Associate WAF Web ACL with ALB
############################################
# WHY: This actually attaches the WAF to your ALB so it inspects traffic
resource "aws_wafv2_web_acl_association" "ultram_alb_waf" {
  resource_arn = aws_lb.ultram_alb01.arn
  web_acl_arn  = aws_wafv2_web_acl.ultram_waf.arn
}

############################################
# 9) CloudWatch Alarm: ALB 5xx Errors
############################################
# WHY: Monitors for server-side errors and alerts via SNS when threshold is exceeded
# This helps detect application or infrastructure problems quickly
resource "aws_cloudwatch_metric_alarm" "ultram_alb_5xx_alarm" {
  alarm_name          = var.alb_5xx_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alb_5xx_period_seconds  # 300 seconds = 5 minutes
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold  # Alert if more than 5 errors
  alarm_description   = "Alarm when ALB target 5xx errors exceed ${var.alb_5xx_threshold}"
  treat_missing_data  = "notBreaching"  # Don't alarm if no data

  # Match this alarm to your specific ALB
  dimensions = {
    LoadBalancer = aws_lb.ultram_alb01.arn_suffix
  }

  # Send notifications to SNS topic
  alarm_actions = [aws_sns_topic.ops_alerts.arn]
  ok_actions    = [aws_sns_topic.ops_alerts.arn]

  tags = {
    Name = var.alb_5xx_alarm_name
  }
}

############################################
# 10) CloudWatch Dashboard for ALB Metrics
############################################
# WHY: Provides a centralized view of ALB health and performance metrics
# Essential for monitoring and troubleshooting
resource "aws_cloudwatch_dashboard" "ultram_alb_dashboard" {
  dashboard_name = var.alb_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum", label = "Total Requests" }],
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "ALB Request Count"
          dimensions = {
            LoadBalancer = aws_lb.ultram_alb01.arn_suffix
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", { stat = "Sum", label = "2xx Success" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum", label = "4xx Client Errors" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum", label = "5xx Server Errors" }],
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "ALB Response Codes"
          dimensions = {
            LoadBalancer = aws_lb.ultram_alb01.arn_suffix
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Avg Response Time" }],
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Target Response Time (seconds)"
          dimensions = {
            LoadBalancer = aws_lb.ultram_alb01.arn_suffix
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", { stat = "Average", label = "Healthy Targets" }],
            [".", "UnHealthyHostCount", { stat = "Average", label = "Unhealthy Targets" }],
          ]
          period = 60
          stat   = "Average"
          region = var.region
          title  = "Target Health Status"
          dimensions = {
            TargetGroup  = aws_lb_target_group.ultram_tg01.arn_suffix
            LoadBalancer = aws_lb.ultram_alb01.arn_suffix
          }
        }
      },
    ]
  })
}
