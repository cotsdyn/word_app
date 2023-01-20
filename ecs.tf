# our ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs"
}

# a log group for our app logs
resource "aws_cloudwatch_log_group" "applogs" {
  name = "word_app"
}



# register our db_init container as a task definition in ECS Fargate
data "template_file" "db_init" {
  template = "${file("./fargate_tasks/db_init.json")}"
  vars = {
    ecr_image_uri = "${aws_ecr_repository.db_init.repository_url}:latest"
    db_hostname   = "${aws_db_instance.db.address}"
    db_name       = "${data.env_variable.DB_NAME.value}"
    db_username   = "${data.env_variable.DB_USERNAME.value}"
    db_password   = "${data.env_variable.DB_PASSWORD.value}"
  }
}

resource "aws_ecs_task_definition" "db_init" {
  family                   = "db_init"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions    = "${data.template_file.db_init.rendered}"
}



# register our word_app container as a task definition in ECS Fargate
data "template_file" "word_app" {
  template = "${file("./fargate_tasks/word_app.json")}"
  vars = {
    ecr_image_uri = "${aws_ecr_repository.word_app.repository_url}:latest"
    db_hostname   = "${aws_db_instance.db.address}"
    db_name       = "${data.env_variable.DB_NAME.value}"
    db_username   = "${data.env_variable.DB_USERNAME.value}"
    db_password   = "${data.env_variable.DB_PASSWORD.value}"
  }
}

resource "aws_ecs_task_definition" "word_app" {
  family                   = "word_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions    = "${data.template_file.word_app.rendered}"
}

# get the "default" subnets in the default VPC
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "webports" {
  name        = "webports"
  description = "Allow webports inbound"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description      = "p80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    description      = "p5000"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = [
      "0.0.0.0/0"
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

# run the container as a service
resource "aws_ecs_service" "word_app" {
  name                = "word_app"
  cluster             = aws_ecs_cluster.main.id
  task_definition     = aws_ecs_task_definition.word_app.arn
  desired_count       = 3
  launch_type         = "FARGATE"

  network_configuration {
    security_groups = [
      data.aws_security_group.default.id,
      aws_security_group.webports.id
    ]
    subnets           = data.aws_subnets.default.ids
    assign_public_ip  = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = "word_app_container"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
}
