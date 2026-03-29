resource "aws_nat_gateway" "man_up" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "lb" {
  
  domain   = "vpc"
}