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

# Container Registries are in ecr.tf
# ECS Fargate cluster and jobs are in ecs.tf
# Environment Variables are made available as a data source in env_vars.tf
# VPC Security Groups are in security_groups.tf
