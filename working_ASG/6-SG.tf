resource "aws_security_group" "web_server" {
  name        = "web_server"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.man_up.id

}

resource "aws_vpc_security_group_ingress_rule" "web_server" {
  security_group_id = aws_security_group.web_server.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# resource "aws_vpc_security_group_ingress_rule" "ssh_access" {
#   security_group_id = aws_security_group.web_server.id
#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 22
#   ip_protocol = "tcp"
#   to_port     = 22
# }

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.web_server.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
} 

resource "aws_security_group" "lt" {
  name        = "web_lt"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.man_up.id

}

resource "aws_vpc_security_group_ingress_rule" "web_lt" {
  security_group_id = aws_security_group.lt.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_lt" {
  security_group_id = aws_security_group.lt.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "alb" {
  name        = "web_alb"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.man_up.id

}

resource "aws_vpc_security_group_ingress_rule" "web_alb" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "egress-alb" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

