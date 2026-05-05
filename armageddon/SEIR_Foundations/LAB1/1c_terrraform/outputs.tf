# Explanation: Outputs are your mission report—what got built and where to find it.
output "ultram_vpc_id" {
  value = aws_vpc.ultram_vpc_01.id
}

output "var.public_subnet_ids" {
  value = aws_subnet.public_subnet_cidrs[*].id
}

output "var.private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "ec2-lab-app.id" {
  value = aws_instance.ec2-lab-app.id
}

output "lab-mysql" {
  value = aws_db_instance.lab-mysql.id
}

output "ops_alert_arn" {
  value = aws_sns_topic.ops_alert.arn
}

output "var.app_log_group_name.name" {
  value = aws_cloudwatch_log_group.app_log_group_name.name
}
