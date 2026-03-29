resource "aws_launch_template" "man-up-lt" {
  name = "man-up-lt"
  description = "Launch template for man-up ASG"
  image_id = "ami-0bdd88bd06d16ba03"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_server.id]
  user_data = filebase64("user_data.sh")  
}



# data "aws_ami" "amzn-linux-2023-ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023.*-x86_64"]
#   }
# }

# resource "aws_launch_template" "man-up-lt" {
#   name_prefix   = "man-up-lt"
#   image_id      = data.aws_ami.amzn-linux-2023-ami.id
#   instance_type = "t3.micro"

#   vpc_security_group_ids = [aws_security_group.man-up-tg.id]

#   user_data = filebase64("./user_data.sh")

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name    = "man-up-asg-instance"
#       Service = "auto-scaling"
#       Owner   = "theo"
#       planet  = "earth"
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }