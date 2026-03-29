resource "aws_instance" "man_up-ec2" {
  ami           = "ami-0bdd88bd06d16ba03"
   instance_type = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_server.id]
  subnet_id     = aws_subnet.public-us-east-1a.id

  user_data = file("user_data.sh")

  tags = {
    Name = "Web-Server"
  }
}   

