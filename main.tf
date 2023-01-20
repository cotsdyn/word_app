terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    env = {
      source = "tchupp/env"
      version = "0.0.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "env" {}

# get the "default" AWS security group in the default VPC
data "aws_security_group" "default" {
  name = "default"
}

# a Container Registry for our "word_app" Docker images
resource "aws_ecr_repository" "repo" {
  name                 = "word_app"
  image_tag_mutability = "MUTABLE"
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

# the app's MySQL database
data "env_variable" "DB_NAME" {
  name = "DB_NAME"
}

data "env_variable" "DB_USERNAME" {
  name = "DB_USERNAME"
}

data "env_variable" "DB_PASSWORD" {
  name = "DB_PASSWORD"
}

resource "aws_db_instance" "db" {
  identifier           = "words"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = data.env_variable.DB_USERNAME.value
  password             = data.env_variable.DB_PASSWORD.value
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  # allow access from our offices
  publicly_accessible    = true
  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.mysql_admin_from_offices.id
  ]
}
