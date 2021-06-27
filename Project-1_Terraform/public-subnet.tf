resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.project-1-vpc.id
    cidr_block = "10.0.101.0/24"

    tags = {
      "Name" = "Public-Subnet"
    }
  
}