output "ssm_parameter_names" {
  value = [
    aws_ssm_parameter.db_endpoint.name,
    aws_ssm_parameter.db_port.name,
    aws_ssm_parameter.db_name.name
  ]
}

# output "secrets_manager_secret_name" {
#   value = aws_secretsmanager_secret.db.name
# }

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.db_errors_alarm.alarm_name
}

# # output "ec2_instance_profile_name" {
#   value       = var.create_ec2_instance_profile ? aws_iam_instance_profile.ec2_profile[0].name : null
#   description = "Attach this instance profile to your EC2 instance (if Terraform didn't create the EC2 resource)."
# # }

############################################
# Bonus-B Outputs
############################################

# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID for ultra-m.com (needed for manual NS update at registrar)"
  value       = aws_route53_zone.ultram_zone.zone_id
}

output "route53_name_servers" {
  description = "Name servers for your domain - update these at your domain registrar"
  value       = aws_route53_zone.ultram_zone.name_servers
}

# ACM Certificate Outputs
output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate.ultram_cert.arn
}

output "acm_certificate_status" {
  description = "Validation status of the ACM certificate"
  value       = aws_acm_certificate.ultram_cert.status
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.ultram_alb01.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.ultram_alb01.arn
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (for Route53 alias records)"
  value       = aws_lb.ultram_alb01.zone_id
}

output "alb_url" {
  description = "Full HTTPS URL to access your application"
  value       = "https://${var.tls_domain_name}"
}

# Target Group Outputs
output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.ultram_tg01.arn
}

# WAF Outputs
output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.ultram_waf.arn
}

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.ultram_waf.id
}

# CloudWatch Outputs
output "alb_5xx_alarm_name" {
  description = "Name of the ALB 5xx error CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.ultram_alb_5xx_alarm.alarm_name
}

output "alb_dashboard_name" {
  description = "Name of the CloudWatch dashboard for ALB metrics"
  value       = aws_cloudwatch_dashboard.ultram_alb_dashboard.dashboard_name
}

output "alb_dashboard_url" {
  description = "Direct URL to CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${var.alb_dashboard_name}"
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.ultram_alb_sg01.id
}

############################################
# Verification Commands Summary
############################################
output "verification_commands" {
  description = "CLI commands to verify Bonus-B deployment"
  value = <<-EOT
  
  === Bonus-B Verification Commands ===
  
  1. Check ALB status:
  aws elbv2 describe-load-balancers --names ${var.alb_name} --query "LoadBalancers[0].State.Code"
  
  2. Check HTTPS listener exists:
  aws elbv2 describe-listeners --load-balancer-arn ${aws_lb.ultram_alb01.arn} --query "Listeners[].Port"
  
  3. Check target health:
  aws elbv2 describe-target-health --target-group-arn ${aws_lb_target_group.ultram_tg01.arn}
  
  4. Check WAF attachment:
  aws wafv2 get-web-acl-for-resource --resource-arn ${aws_lb.ultram_alb01.arn} --scope REGIONAL --region ${var.region}
  
  5. Check CloudWatch alarm:
  aws cloudwatch describe-alarms --alarm-name-prefix ${var.alb_5xx_alarm_name}
  
  6. Check CloudWatch dashboard:
  aws cloudwatch list-dashboards --dashboard-name-prefix ${var.alb_dashboard_name}
  
  7. Test your application:
  curl -I https://${var.tls_domain_name}
  
  === Important Next Steps ===
  
  After Terraform completes:
  1. Update your domain registrar's nameservers to:
     ${join("\n     ", aws_route53_zone.ultram_zone.name_servers)}
  
  2. Wait for DNS propagation (can take up to 48 hours, usually <1 hour)
  
  3. Access your app at: https://${var.tls_domain_name}
  
  4. Monitor your dashboard: ${aws_cloudwatch_dashboard.ultram_alb_dashboard.dashboard_name}
  
  EOT
}
