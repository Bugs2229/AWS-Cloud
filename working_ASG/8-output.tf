output "ip_address" {
  value = aws_instance.man_up-ec2.public_ip
}

output "website_url" {
    value = "http://${aws_lb.man-up-alb.dns_name}"
}