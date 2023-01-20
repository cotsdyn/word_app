
# get the "default" AWS security group in the default VPC
data "aws_security_group" "default" {
  name = "default"
}

# security group to allow MySQL administration from the offices
resource "aws_security_group" "mysql_admin_from_offices" {
  name        = "mysql_admin_from_offices"
  description = "Allow MySQL admin from our office IPs"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description      = "MySQL inbound"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [
      "87.115.86.44/32"  # alex's oxford office
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
