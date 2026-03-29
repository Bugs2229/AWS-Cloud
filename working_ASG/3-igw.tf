resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.man_up.id

  tags = {
    Name    = "internet_gateway"
    Service = "application1"
    Owner   = "Jason"
    Planet  = "Lee"
  }
}