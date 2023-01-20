# a Container Registries for our "db_init" and "word_app" Docker images
resource "aws_ecr_repository" "db_init" {
  name                 = "db_init"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "word_app" {
  name                 = "word_app"
  image_tag_mutability = "MUTABLE"
}
