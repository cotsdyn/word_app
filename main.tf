terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_security_group" "sg_default" {
  name = "default"
}
data "aws_security_group" "sg_mysqlremote" {
  name = "mysqlremote"
}

resource "aws_db_instance" "db" {
  identifier           = "db-words"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "easelivedemo123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  publicly_accessible    = true
  vpc_security_group_ids = [
    data.aws_security_group.sg_default.id,
    data.aws_security_group.sg_mysqlremote.id
  ]
}
