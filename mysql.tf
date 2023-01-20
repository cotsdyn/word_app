# the app's MySQL database
resource "aws_db_instance" "db" {
  identifier           = "words"
  db_name              = data.env_variable.DB_NAME.value
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
