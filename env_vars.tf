provider "env" {}

data "env_variable" "DB_NAME" {
  name = "DB_NAME"
}

data "env_variable" "DB_USERNAME" {
  name = "DB_USERNAME"
}

data "env_variable" "DB_PASSWORD" {
  name = "DB_PASSWORD"
}
