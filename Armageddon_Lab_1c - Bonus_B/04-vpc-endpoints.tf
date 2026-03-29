resource "aws_vpc_endpoint" "interface" {
  for_each            = local.interface_endpoints
  vpc_id              = aws_vpc.ultram_vpc_01.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce.id]

  tags = {
    Name = "vpce-${each.key}"
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.ultram_vpc_01.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private.id]

   tags = {
    Name = "vpce-s3-gateway"
  }
}

locals {
  interface_endpoints = toset([
    "ssm",
    "ec2messages",
    "ssmmessages",
    "logs",
    "secretsmanager",
    # "kms", # optional but realistic
  ])
}





