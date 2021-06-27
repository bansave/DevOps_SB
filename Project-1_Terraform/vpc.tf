resource "aws_vpc" "project-1-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "project-1-prod"
    }
  
}