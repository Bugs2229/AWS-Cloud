resource "aws_lb_target_group" "alb" {
  name        = "tf-lb-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.man_up.id
}

   
    