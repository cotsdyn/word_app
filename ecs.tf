# our ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs"
}

# a log group for our app logs
resource "aws_cloudwatch_log_group" "applogs" {
  name = "word_app"
}

# run our DB setup script in ECS Fargate

# run our app container in ECS Fargate
data "template_file" "word_app" {
  template = "${file("./fargate_tasks/word_app.json")}"
  vars = {
    ecr_image_uri = "${aws_ecr_repository.repo.repository_url}:latest"
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
