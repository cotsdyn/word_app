# our ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs"
}

# IAM "execution role" to allow ECS to execute tasks
# (we are using the AWS-provided default) 
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "role-name-task"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#resource "aws_iam_role_policy_attachment" "task_s3" {
#  role       = "${aws_iam_role.ecs_task_role.name}"
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}


# a log group for our app logs
resource "aws_cloudwatch_log_group" "applogs" {
  name = "word_app"
}

# run our DB setup script in ECS Fargate

# run our app container in ECS Fargate
resource "aws_ecs_task_definition" "word_app" {
  family                   = "word_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
  name        = "word_app_container"
  image       = "${aws_ecr_repository.repo.repository_url}:latest"
  essential   = true
  
  "environment": [
      {
        "name": "DB_HOSTNAME",
        "value": "${aws_db_instance.db.address}"
      },
      {
        "name": "DB_NAME",
        "value": "${data.env_variable.DB_NAME.value}"
      },
      {
        "name": "DB_USERNAME",
        "value": "${data.env_variable.DB_USERNAME.value}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${data.env_variable.DB_PASSWORD.value}"
      }
    ]

  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-region" : "us-east-1",
      "awslogs-group" : "word_app",
      "awslogs-stream-prefix" : "project"
    }
  },

  portMappings = [
    {
      protocol      = "tcp"
      containerPort = 5000
      hostPort      = 5000
    }
  ]
  }])
}
