resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.project-1-vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
      "Name" = "Private-Subnet"
    }
  
}

resource "aws_nat_gateway" "project-1-private" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private-subnet.id

  tags = {
    "Name" = "Private-NAT"
  }
}