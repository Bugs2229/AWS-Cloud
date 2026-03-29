# resource "aws_sns_topic" "asg_actions" {
#   name = "asg_actions"
# }

# resource "aws_sns_topic_subscription" "asg_actions" {
#   topic_arn = (aws_sns_topic.asg_actions.arn)
#    protocol  = "email"
#   endpoint  = "ladorian@hotmail.com"
 
# }
    
# resource "aws_autoscaling_notification" "example_notifications" {
#   group_names = [
#     aws_autoscaling_group.bar.name,
#     aws_autoscaling_group.foo.name,
#   ]

#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCH",
#     "autoscaling:EC2_INSTANCE_TERMINATE",
#     "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
#     "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
#   ]

#   topic_arn = aws_sns_topic.example.arn
# }
