terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "../Networking"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_service" "ecs_web" {
  name             = "web-service"
  cluster          = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.web_task_def.arn
  launch_type      = "FARGATE"
  desired_count    = 2

  network_configuration {
    subnets = module.networking.public_subnets
    security_groups = [module.networking.security_group_id]
  }
}


resource "aws_ecs_task_definition" "web_task_def" {
  family                   = "web-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "web-container"
      image = "nginx:latest"
    },
  ])
}
